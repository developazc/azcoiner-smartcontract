// SPDX-License-Identifier: BUSL-1.1

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IToken.sol";
pragma solidity ^0.8.27;

contract Treasury is Ownable {
    mapping(address => bool) public counterparties;
    IToken public token;

    modifier onlyCounterparty() {
        require(counterparties[msg.sender], "Only counterparty can mint");
        _;
    }

    constructor() Ownable(msg.sender) {}

    /*
     * @dev Set a counterparty
     * @param counterparty The address of the counterparty
     */
    function setCounterparty(address counterparty) public onlyOwner {
        counterparties[counterparty] = true;
    }

    /*
     * @dev Revoke a counterparty
     * @param counterparty The address of the counterparty
     */
    function revokeCounterparty(address counterparty) public onlyOwner {
        counterparties[counterparty] = false;
    }

    /*
     * @dev Mint tokens
     * @param recipient The address to mint to
     * @param amount The amount of tokens to mint
     */
    function mintToken(
        address recipient,
        uint256 amount
    ) public onlyCounterparty {
        token.mint(recipient, amount);
    }

    /*
     * @dev Set the token
     * @param token_ The address of the token
     */
    function setToken(IToken token_) public onlyOwner {
        token = token_;
    }
}
