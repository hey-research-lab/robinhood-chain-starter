# Robinhood Chain starter

A small Foundry + viem template for building on Robinhood Chain (chain id 4663, an Arbitrum Orbit L2 that settles to Ethereum). Clone it and you have a contract with tests, a deploy script, and read-only TypeScript scripts that need no front end.

> Community-made by HEY Research Lab · not an official Robinhood resource.

## What is in it

```
src/Counter.sol               the example contract
src/IMulticall3.sol           minimal Multicall3 interface and address
test/Counter.t.sol            unit and fuzz tests
test/Multicall3.fork.t.sol    read-only fork test (opt-in, see below)
script/Deploy.s.sol           deploys Counter
script/ReadMulticall.s.sol    batches six token reads through Multicall3, never broadcasts
ts/src/chain-info.ts          viem: chain id and latest block
ts/src/multicall.ts           viem: one batched read through Multicall3
```

## Chain facts

| Fact | Value | Source |
| --- | --- | --- |
| Chain id | `4663` | [Robinhood Chain docs, Connecting](https://docs.robinhood.com/chain/connecting/); `eth_chainId` on the RPC returns `0x1237` |
| Native gas token | ETH | [Robinhood Chain docs, Connecting](https://docs.robinhood.com/chain/connecting/) |
| Public RPC | `https://rpc.mainnet.chain.robinhood.com` (rate-limited, not for production) | [Robinhood Chain docs, Connecting](https://docs.robinhood.com/chain/connecting/) |
| Explorer | [robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com) | [Robinhood Chain docs, Connecting](https://docs.robinhood.com/chain/connecting/) |
| Multicall3 | `0xcA11bde05977b3631167028862bE2a173976CA11` | viem's [`robinhood` chain definition](https://github.com/wevm/viem/blob/main/src/chains/definitions/robinhood.ts); [Sourcify exact match on 4663](https://sourcify.dev/server/v2/contract/4663/0xcA11bde05977b3631167028862bE2a173976CA11) |
| WETH (used in the examples) | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | [Robinhood Chain docs, Contracts](https://docs.robinhood.com/chain/contracts) |
| USDG (used in the examples) | `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` | [Robinhood Chain docs, Contracts](https://docs.robinhood.com/chain/contracts) |

For production traffic, use one of the RPC providers listed on the Connecting page.

## Prerequisites

- [Foundry](https://getfoundry.sh) (`forge`, `cast`). CI uses v1.8.5.
- Node.js 20 or later, for `ts/`.
- Some ETH on Robinhood Chain, only if you deploy.

## Setup

```sh
git clone --recurse-submodules https://github.com/hey-research-lab/robinhood-chain-starter.git
cd robinhood-chain-starter
forge build
forge test
```

If you cloned without `--recurse-submodules`, run `git submodule update --init --recursive` to fetch `forge-std`.

`foundry.toml` defines a `robinhood` RPC alias pointing at the public endpoint, so `--rpc-url robinhood` works everywhere below. To use your own provider, pass its URL to `--rpc-url` instead.

### Read the chain from Solidity (no transaction)

```sh
# Batches symbol, decimals and totalSupply of WETH and USDG into one Multicall3 call
forge script script/ReadMulticall.s.sol --rpc-url robinhood

# Fork tests against mainnet state (skipped by default so CI never needs an RPC)
RUN_FORK_TESTS=true forge test --match-path test/Multicall3.fork.t.sol -vv
```

## Deploy

Run the script without `--broadcast` first. That is a dry run: it simulates the deployment and sends nothing.

```sh
forge script script/Deploy.s.sol --rpc-url robinhood
```

To deploy for real, keep your key in Foundry's encrypted keystore rather than in a file or your shell history:

```sh
cast wallet import deployer --interactive   # paste the key once; it is stored encrypted
forge script script/Deploy.s.sol --rpc-url robinhood --account deployer --broadcast
```

If you must use an environment variable, set it yourself in your shell (never in a committed file) and pass it in:

```sh
forge script script/Deploy.s.sol --rpc-url robinhood --private-key "$PRIVATE_KEY" --broadcast
```

`.env` is git-ignored. Nothing in this repository holds a key, and CI never deploys or sends a transaction.

## Verify

### Blockscout

Robinhood Chain's explorer is a Blockscout instance. Foundry verifies against its Etherscan-compatible API at `<explorer>/api/`:

```sh
forge verify-contract <DEPLOYED_ADDRESS> src/Counter.sol:Counter \
  --rpc-url robinhood \
  --verifier blockscout \
  --verifier-url https://robinhoodchain.blockscout.com/api/
```

You can also verify while deploying by adding `--verify --verifier blockscout --verifier-url https://robinhoodchain.blockscout.com/api/` to the `forge script ... --broadcast` command.

### Sourcify (alternative)

[Sourcify](https://sourcify.dev) supports chain 4663 and needs no API key:

```sh
forge verify-contract <DEPLOYED_ADDRESS> src/Counter.sol:Counter \
  --rpc-url robinhood \
  --verifier sourcify
```

## Read with viem

viem ships Robinhood Chain as `robinhood` in `viem/chains`, with Multicall3 already set, so `client.multicall` works without extra configuration.

```sh
cd ts
npm ci
npm run chain-info   # chain id, latest block, timestamp, base fee
npm run multicall    # WETH and USDG symbol, decimals and supply in one Multicall3 call
npm run typecheck
```

Set `ROBINHOOD_RPC_URL` to use your own provider. Both scripts only read.

```ts
import { createPublicClient, http } from 'viem'
import { robinhood } from 'viem/chains'

const client = createPublicClient({ chain: robinhood, transport: http() })
console.log(await client.getBlockNumber())
```

## Arbitrum notes

- **`block.number` is Ethereum's block number.** On Arbitrum chains, `block.number` inside a contract returns an approximate parent-chain (Ethereum) block number, not the Robinhood Chain block. For the L2 block number, call `ArbSys(0x0000000000000000000000000000000000000064).arbBlockNumber()`. For example, `Multicall3.getBlockNumber()` on mainnet returns a number close to Ethereum's head, while `eth_blockNumber` returns the much larger L2 number. A local Foundry fork does not reproduce this: there `block.number` is the forked L2 block.
- **EVM version.** `foundry.toml` targets `cancun`. The chain accepts Cancun opcodes (`TSTORE`, `TLOAD`, `MCOPY`).
- **Fees.** A transaction pays for L2 execution plus its share of posting data to Ethereum, so gas estimates from tools that do not model the L1 part can differ from what you pay.

## Get your project seen

Building on Robinhood Chain? List your project on [HEY Research Lab](https://heyresearch.xyz), the public record of building on Robinhood Chain — every ship with its source.

## License

[MIT](LICENSE)
