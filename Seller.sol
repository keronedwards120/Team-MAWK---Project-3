pragma solidity >=0.4.22 <=0.6.1;

import "./ISeller.sol";

contract Seller is ISeller{
    address payable public seller_address;
    bool public isExist;
    event RegisterSeller(address seller);
    constructor(address payable _beneficiary) public {
        seller_address = _beneficiary;
        isExist = true;
    }
}