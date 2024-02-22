import { ethers } from 'hardhat';

async function main() {
  const [deployer] = await ethers.getSigners();
  const monoswapV2Factory = await ethers.deployContract(
    'MonoswapV2Factory',
    [deployer.address],
    {}
  );

  console.log(
    'MonoswapV2Factory deployed to:',
    await monoswapV2Factory.getAddress()
  );

  console.log('Init code hash:', await monoswapV2Factory.INIT_CODE_POOL_HASH());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
