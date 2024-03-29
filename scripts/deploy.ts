import { ethers } from 'hardhat';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  const monoswapV2Factory = await ethers.deployContract(
    'MonoswapV2Factory',
    [
      deployer.address, // feeToSetter
      '0x4300000000000000000000000000000000000002', // blast
      '0x2fc95838c71e76ec69ff817983BFf17c710F34E0', // blastPoints
      '0x4200000000000000000000000000000000000022', // usdb
      '0x4200000000000000000000000000000000000023', // weth
      deployer.address, // operator
    ],
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
