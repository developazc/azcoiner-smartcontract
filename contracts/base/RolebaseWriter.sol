// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract RolebaseWriter is AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");

    function __RolebaseWriter_init(address admin) public initializer {
        __AccessControl_init();
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(WRITER_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(WRITER_ROLE, admin);
    }

    modifier onlyWriter() {
        require(hasRole(WRITER_ROLE, msg.sender), "Caller is not a writer");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    function grantWriter(address account) public onlyAdmin {
        _grantRole(WRITER_ROLE, account);
    }

    function grantWriters(address[] memory accounts) public onlyAdmin {
        for (uint256 i = 0; i < accounts.length; i++) {
            _grantRole(WRITER_ROLE, accounts[i]);
        }
    }

    function revokeWriter(address account) public onlyAdmin {
        _revokeRole(WRITER_ROLE, account);
    }
}
