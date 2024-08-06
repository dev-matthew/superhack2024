// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@pythnetwork/pyth-sdk-solidity/IPyth.sol";

contract SecretSantaFactory {

    struct Gift {
        address token;
        uint256 amount;
    }

    struct SecretSanta {
        address santa;
        uint256 usdc_value;
        uint256 usdc_value_margin;
        bool valid;
        mapping(address => Gift) gifts;
    }

    IPyth pyth;
    uint256 private count;
    mapping(uint256 => SecretSanta) private secret_santas;

    constructor(address _pyth) {
        pyth = IPyth(_pyth);
        count = 0;
    }

    function create(uint256 _usdc_value, uint256 _usdc_value_margin) public returns (uint256) {
        uint256 id = count;
        secret_santas[id].santa = msg.sender;
        secret_santas[id].usdc_value = _usdc_value;
        secret_santas[id].usdc_value_margin = _usdc_value_margin;
        secret_santas[id].valid = true;
        count++;
        return id;
    }

    function join(uint256 _id, address _token, uint256 _amount) public {
        require(secret_santas[_id], "Secret Santa ID not found.");
        require(secret_santas[_id].valid, "Secret Santa ID has ended.");
        // TODO: check worldcoin ID is valid
        // TODO: use Pyth to make sure it falls in the correct value range
        secret_santas[_id].gifts[msg.sender] = Gift(_token, _amount);
    }

    function end(uint256 _id) public {
        require(secret_santas[_id], "Secret Santa ID not found.");
        require(secret_santas[_id].santa == msg.sender, "You are not Santa!");
        secret_santas[_id].valid = false;
    }

    function claim(uint256 _id) public {
        require(secret_santas[_id], "Secret Santa ID not found.");
        require(!secret_santas[_id].valid, "Secret Santa ID has not been ended.");
        require(secret_santas[_id].gifts[msg.sender], "You never gave a gift!");
        // TODO: use Pyth to randomly get something from the remaining gifts
    }
}
