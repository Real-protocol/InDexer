// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "./TellorStaking.sol";
import "./interfaces/IController.sol";
import "./Transition.sol";
import "./Getters.sol";

/**
 @author Tellor Inc.
 @title Controller
 @dev This is the Controller contract which defines the functionality for
 * changing contract addresses, as well as minting and migrating tokens
*/
contract Controller is TellorStaking, Transition, Getters {
    // Events
    event NewContractAddress(address _newContract, string _contractName);

    uint256 public emissionrate = 146.94 ether;

    // Functions
    /**
     * @dev Saves new Tellor contract addresses. Available to Transition init function after fork vote
     * @param _governance is the address of the Governance contract
     * @param _oracle is the address of the Oracle contract
     * @param _treasury is the address of the Treasury contract
     */
    constructor(
        address _governance,
        address _oracle,
        address _treasury,
        address _feemanager,
        address _deployer
    ) Transition(_governance, _oracle, _treasury, _feemanager, _deployer) {}

    /**
     * @dev Changes Controller contract to a new address
     * Note: this function is only callable by the Governance contract.
     * @param _newController is the address of the new Controller contract
     */
    function changeControllerContract(address _newController) external {
        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Controller contract address"
        );
        require(_isValid(_newController));
        addresses[_TELLOR_CONTRACT] = _newController; //name _TELLOR_CONTRACT is hardcoded in
        assembly {
            sstore(_EIP_SLOT, _newController)
        }
        emit NewContractAddress(_newController, "Controller");
    }

    /**
     * @dev Changes Governance contract to a new address
     * Note: this function is only callable by the Governance contract.
     * @param _newGovernance is the address of the new Governance contract
     */
    function changeGovernanceContract(address _newGovernance) external {
        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Governance contract address"
        );
        require(_isValid(_newGovernance));
        addresses[_GOVERNANCE_CONTRACT] = _newGovernance;
        emit NewContractAddress(_newGovernance, "Governance");
    }

    /**
     * @dev Changes Oracle contract to a new address
     * Note: this function is only callable by the Governance contract.
     * @param _newOracle is the address of the new Oracle contract
     */
    function changeOracleContract(address _newOracle) external {
        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Oracle contract address"
        );
        require(_isValid(_newOracle));
        addresses[_ORACLE_CONTRACT] = _newOracle;
        emit NewContractAddress(_newOracle, "Oracle");
    }

    /**
     * @dev Changes Treasury contract to a new address
     * Note: this function is only callable by the Governance contract.
     * @param _newTreasury is the address of the new Treasury contract
     */
    function changeTreasuryContract(address _newTreasury) external {
        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Treasury contract address"
        );
        require(_isValid(_newTreasury));
        addresses[_TREASURY_CONTRACT] = _newTreasury;
        emit NewContractAddress(_newTreasury, "Treasury");
    }

    function changefeemanager(address _newfeemanager) external {
        require(
            msg.sender == addresses[Feemanager],
            "Only the feemanager contract can change the feemanager address"
        );
        addresses[Feemanager] = _newfeemanager;
    }

    function changedeployermanager(address _newdeployer) external {
        require(
            msg.sender == addresses[Deployer],
            "Only the feemanager contract can change the feemanager address"
        );
        addresses[Deployer] = _newdeployer;
    }

    /**
     * @dev Changes a uint for a specific target index
     * Note: this function is only callable by the Governance contract.
     * @param _target is the index of the uint to change
     * @param _amount is the amount to change the given uint to
     */
    function changeUint(bytes32 _target, uint256 _amount) external {
        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the uint"
        );
        uints[_target] = _amount;
    }

    function setEmissionRate(uint256 value) external {
        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the uint"
        );
        emissionrate = value;
    }

    /**
     * @dev Mints tokens of the sender from the old contract to the sender
     */
    function migrate() external {
        require(!migrated[msg.sender], "Already migrated");
        _doMint(
            msg.sender,
            IController(addresses[_OLD_TELLOR]).balanceOf(msg.sender)
        );
        migrated[msg.sender] = true;
    }

    /**
     * @dev Mints TRB to a given receiver address
     * @param _receiver is the address that will receive the minted tokens
     * @param _amount is the amount of tokens that will be minted to the _receiver address
     */
    function mint(address _receiver, uint256 _amount) external {
        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT] ||
                msg.sender == addresses[_TREASURY_CONTRACT] ||
                msg.sender == TELLOR_ADDRESS,
            "Only governance, treasury, or master can mint tokens"
        );
        _doMint(_receiver, _amount);
    }

    //sets emission rate to oracle and team
    function mintTooracle() external {
         require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT] ||
                msg.sender == addresses[_ORACLE_CONTRACT] ||
                msg.sender == TELLOR_ADDRESS,
            "Only governance, oracle, or master can mint new emission tokens"
        );

        // X - 0.02X = 144 daily time based rewards. X = 146.94
        uint256 _releasedAmount = (emissionrate * //change to state variable
            (block.timestamp - uints[keccak256("_LAST_RELEASE_TIME_DAO")])) /
            86400;
        uints[keccak256("_LAST_RELEASE_TIME_DAO")] = block.timestamp;
        _doMint(addresses[_ORACLE_CONTRACT], _releasedAmount);
    }

    function mintToDev() external {
        uint256 _releasedAmount = (emissionrate * //change to state variable
            (block.timestamp - uints[keccak256("_LAST_RELEASE_TIME_TEAM")])) /
            86400;
        uints[keccak256("_LAST_RELEASE_TIME_DAO")] = block.timestamp;
        _doMint(addresses[Feemanager], _releasedAmount);
    }

    /**
     * @dev Used during the upgrade process to verify valid Tellor Contracts
     */
    function verify() external pure returns (uint256) {
        return 9999;
    }

    /**
     * @dev Used during the upgrade process to verify valid Tellor Contracts and ensure
     * they have the right signature
     * @param _contract is the address of the Tellor contract to verify
     * @return bool of whether or not the address is a valid Tellor contract
     */
    function _isValid(address _contract) internal returns (bool) {
        (bool _success, bytes memory _data) = address(_contract).call(
            abi.encodeWithSelector(0xfc735e99, "") // verify() signature
        );
        require(
            _success && abi.decode(_data, (uint256)) > 9000, // An arbitrary number to ensure that the contract is valid
            "New contract is invalid"
        );
        return true;
    }
}
