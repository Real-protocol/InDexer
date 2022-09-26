// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "./tellor3/TellorVariables.sol";

/**
 @author Tellor Inc.
 @title TellorVariables
 @dev Helper contract to store hashes of variables.
 * For each of the bytes32 constants, the values are equal to
 * keccak256([VARIABLE NAME])
*/
contract TellorVars is TellorVariables {
    // Storage
    address constant TELLOR_ADDRESS =
        0x81Dd9cc325ECa58456EfC16575874fCB19D883dB; // Address of main Tellor Contract 
        //todo change address
    // Hashes for each pertinent contract
    bytes32 constant _GOVERNANCE_CONTRACT =
        0xefa19baa864049f50491093580c5433e97e8d5e41f8db1a61108b4fa44cacd93;
    bytes32 constant _ORACLE_CONTRACT =
        0xfa522e460446113e8fd353d7fa015625a68bc0369712213a42e006346440891e;
    bytes32 constant _TREASURY_CONTRACT =
        0x1436a1a60dca0ebb2be98547e57992a0fa082eb479e7576303cbd384e934f1fa;
    bytes32 constant _SWITCH_TIME =
        0x6c0e91a96227393eb6e42b88e9a99f7c5ebd588098b549c949baf27ac9509d8f;
    bytes32 constant Feemanager = 
        0xde9e04bb0e132eb210d13b7be0812ae264308673cd270182450318f449b7892f;
    bytes32 constant Deployer =
        0x51fabc59101f93463362cc42b2f773f2a0a0262bd1f9698b5d7e54a7094de58d;
    bytes32 constant _MINIMUM_DISPUTE_FEE =
        0x7335d16d7e7f6cb9f532376441907fe76aa2ea267285c82892601f4755ed15f0;
}
