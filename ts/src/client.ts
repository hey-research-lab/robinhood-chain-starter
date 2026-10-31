import { createPublicClient, http } from 'viem'
import { robinhood } from 'viem/chains'

// viem ships Robinhood Chain as `robinhood` (chain id 4663), Multicall3 included.
// Set ROBINHOOD_RPC_URL to use your own provider; the public endpoint is rate-limited.
export const client = createPublicClient({
  chain: robinhood,
  transport: http(process.env.ROBINHOOD_RPC_URL ?? 'https://rpc.mainnet.chain.robinhood.com'),
})
