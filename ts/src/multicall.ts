import { erc20Abi, formatUnits, type Address } from 'viem'
import { client } from './client.js'

// From docs.robinhood.com/chain/contracts
const tokens: Record<string, Address> = {
  WETH: '0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73',
  USDG: '0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168',
}

// viem batches these six reads into one eth_call to Multicall3
// (0xcA11bde05977b3631167028862bE2a173976CA11), read from the `robinhood` chain definition.
const addresses = Object.values(tokens)
const results = await client.multicall({
  allowFailure: true,
  contracts: addresses.flatMap((address) => [
    { address, abi: erc20Abi, functionName: 'symbol' } as const,
    { address, abi: erc20Abi, functionName: 'decimals' } as const,
    { address, abi: erc20Abi, functionName: 'totalSupply' } as const,
  ]),
})

addresses.forEach((address, i) => {
  const [symbol, decimals, supply] = results.slice(i * 3, i * 3 + 3).map((r) =>
    r?.status === 'success' ? r.result : undefined,
  )
  if (typeof symbol !== 'string' || typeof decimals !== 'number' || typeof supply !== 'bigint') {
    console.log(`${address}  read failed`)
    return
  }
  console.log(`${symbol.padEnd(6)} ${address}  supply ${formatUnits(supply, decimals)}`)
})
