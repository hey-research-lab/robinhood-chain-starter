import { client } from './client.js'

// Read-only: asks the node for its chain id and latest block. Sends nothing.
const [chainId, block] = await Promise.all([client.getChainId(), client.getBlock()])

console.log(`chain id      ${chainId}`)
console.log(`latest block  ${block.number}`)
console.log(`timestamp     ${new Date(Number(block.timestamp) * 1000).toISOString()}`)
console.log(`base fee      ${block.baseFeePerGas ?? 'n/a'} wei`)
