import { ethers } from 'hardhat';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  const monoswapV2Factory = await ethers.deployContract(
    'MonoswapV2Factory',
    [
      deployer.address, // feeToSetter
      '0x4300000000000000000000000000000000000002', // blast
      '0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800', // blastPoints
      '0x4300000000000000000000000000000000000003', // usdb
      '0x4300000000000000000000000000000000000004', // weth
      deployer.address, // operator
    ],
    {}
  );

  console.log(
    'MonoswapV2Factory deployed to:',
    await monoswapV2Factory.getAddress()
  );

  console.log('Init code hash:', await monoswapV2Factory.INIT_CODE_POOL_HASH());
  console.log('set feeTo');
  await monoswapV2Factory.setFeeTo(deployer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
