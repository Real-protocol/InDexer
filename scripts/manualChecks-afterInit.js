require("hardhat-gas-reporter");
require('hardhat-contract-sizer');
require("solidity-coverage");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
const web3 = require("web3");
const h = require("../test/helpers/helpers");

// npx hardhat run scripts/manualChecks-afterInit.js --network rinkeby
// Note: add second address private key to .env file, TESTNET_PK2=""

// Update these variables before running script
const masterAddress = "0x81Dd9cc325ECa58456EfC16575874fCB19D883dB"
const controllerAddress = "0x5fA7955a8753784fD3f9D28b9f54493d4b0f8CF3"
const oracleAddress = "0x38bD2ef44E88e8c9D0a10DA1FdF662834fb5d6B2"
const governanceAddress = "0xee86d2b9fa4DA66b666d5F4682DD7525bDEa91E0"
const treasuryAddress = "0x9261847990f7aac1C9DCC8DE05A8c5A0Ec99E312"
etherPrice = 4500000000
amplPrice = 1500000
expectedDisputeCount = 10

// Don't change these
let passCount = 0
let failCount = 0

async function manualChecks(_network, _pk, _pk2, _nodeURL) {
    await run("compile")
    await run("compile")

    var net = _network

    ///////////////Connect to the network
    let privateKey = _pk;
    let privateKey2 = _pk2;
    var provider = new ethers.providers.JsonRpcProvider(_nodeURL)
    let wallet = new ethers.Wallet(privateKey, provider)
    let wallet2 = new ethers.Wallet(privateKey2, provider)
    //let contractjson = require('../artifacts/contracts/tellor3/TellorMaster.sol/TellorMaster.json');
    //let abi = contractjson.abi;
    //let master = new ethers.Contract(masterAddress, abi, provider);
    //let master = contract.connect(wallet);
    //let contractjson1 = require('../artifacts/contracts/Oracle.sol/Oracle.json');
    //let oracleabi = contractjson1.abi;
    //let oracle = new ethers.Contract(oracleAddress, oracleabi, provider);
    //let oracle = contract.connect(wallet);
    //let contractjson2 = require('../artifacts/contracts/Governance.sol/Governance.json');
    //let governanceabi = contractjson2.abi;
    //let governance = new ethers.Contract(governanceAddress, governanceabi, provider);
    //let contractjson3 = require('../artifacts/contracts/Controller.sol/Controller.json');
    //let controllerabi = contractjson3.abi;
    //let controller = new ethers.Contract(controllerAddress, controllerabi, provider);



    master = await ethers.getContractAt("contracts/interfaces/ITellor.sol:ITellor", masterAddress)
    //controller = await ethers.getContractAt("contracts/Controller.sol:Controller", controllerAddress)
    oracle = await ethers.getContractAt("contracts/Oracle.sol:Oracle", oracleAddress)
    //governance = await ethers.getContractAt("contracts/Governance.sol:Governance", governanceAddress)
    treasury = await ethers.getContractAt("contracts/Treasury.sol:Treasury", treasuryAddress)



    // *************************************
    // *
    // * After init()
    // *
    // *************************************
    console.log("\nAfter init checks:");

    // Pull old value
    console.log("\nPulling old value...");
    lastNewVal = await oracle.getTimeOfLastNewValue();
    verifyGreaterThan(lastNewVal[0], 0, "pull old value")

    // Add Tip to old ID's (AMPL, ETH/USD)
    /*console.log("\nAdding tip to old ID's (AMPL, ETH/USD)...");
    await oracle.connect(wallet).tipQuery(h.uintTob32(1), web3.utils.toWei("100000000000000000000"), "0x")
    await sleep(15000)
    verifyGreaterThanOrEqualTo(await oracle.getTipsById(h.uintTob32(1)), web3.utils.toWei("100000000000000000000"), "ETH/USD tips in contract")
    await oracle.connect(wallet).tipQuery(h.uintTob32(10), web3.utils.toWei("100000000000000000000"), "0x")
    await sleep(15000)
    verifyGreaterThanOrEqualTo(await oracle.getTipsById(h.uintTob32(10)), web3.utils.toWei("100000000000000000000"), "AMPL/USD tips in contract")*/

    // Mine AMPL/ ETH/USD
    console.log("\nMining AMPL/USD and ETH/USD...");
    await master.connect(wallet).transfer(wallet2.address, web3.utils.toWei("10000"))
    await master.connect(wallet).depositStake()
    await sleep(15000)
    /*await master.connect(wallet2).depositStake()
    await sleep(15000)
    nonce = await oracle.getTimestampCountById(h.uintTob32(1))
    await oracle.connect(wallet).submitValue(h.uintTob32(1), etherPrice, nonce, "0x")
    nonce = await oracle.getTimestampCountById(h.uintTob32(10))
    await oracle.connect(wallet2).submitValue(h.uintTob32(10), amplPrice, nonce, "0x")
    await sleep(15000)

    // Read new values from old contract
    console.log("\nReading new values from old contract...");
    lastNewValEth = await master.getLastNewValueById(1)
    verifyEquals(lastNewValEth[0], etherPrice, "Mine & read ETH/USD")
    lastNewValAmpl = await master.getLastNewValueById(10)
    verifyEquals(lastNewValAmpl[0], amplPrice, "Mine & read AMPL/USD")

    // Ensure no disputes for next week on previous submissions (old stuff)
    console.log("\nEnsuring no disputes on previous submissions (old stuff)...");
    verifyEquals(await master.getUintVar(h.hash("_DISPUTE_COUNT")), expectedDisputeCount, "No disputes on old stuff")
    console.log("Keep checking for new disputes on old values for one week");

    // transfer
    console.log("\nTransferring TRB...");
    bal0 = await master.balanceOf(wallet2.address)
    await master.connect(wallet).transfer(wallet2.address, web3.utils.toWei("100"))
    await sleep(15000)
    bal1 = await master.balanceOf(wallet2.address)
    verifyEquals(bal1.sub(bal0), web3.utils.toWei("100"), "TRB transfer")

    // approve a token
    console.log("\nApproving a token...");
    await master.connect(wallet).approve(wallet2.address, web3.utils.toWei("10"))
    await sleep(15000)
    verifyEquals(await master.allowance(wallet.address, wallet2.address), web3.utils.toWei("10"), "token approval")
    await master.connect(wallet2).transferFrom(wallet.address, wallet2.address, web3.utils.toWei("10"))
    await sleep(15000)
    bal2 = await master.balanceOf(wallet2.address)
    verifyEquals(bal2.sub(bal1), web3.utils.toWei("10"), "TRB transfer")

    console.log("\n" + passCount + "/" + (passCount+failCount) + " checks passed");*/
}

function verifyEquals(firstVal, secondVal, name) {
  if(firstVal == secondVal) {
    console.log(name + " " + "passes");
    passCount++
  } else {
    console.log(name + " " + "fails. expected:" + secondVal + " actual:" + firstVal);
    failCount++
  }
}

function verifyGreaterThan(firstVal, secondVal, name) {
  if(firstVal > secondVal) {
    console.log(name + " " + "passes");
    passCount++
  } else {
    console.log(name + " " + "fails. expected greater than:" + secondVal + " actual:" + firstVal);
    failCount++
  }
}

function verifyGreaterThanOrEqualTo(firstVal, secondVal, name) {
  if(firstVal >= secondVal) {
    console.log(name + " " + "passes");
    passCount++
  } else {
    console.log(name + " " + "fails. expected greater than or equal to:" + secondVal + " actual:" + firstVal);
    failCount++
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

manualChecks("rinkeby", process.env.PRIVATE_KEY, process.env.PRIVATE_KEY2, process.env.NODE_URL_RINKEBY)
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
