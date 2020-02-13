pragma solidity >=0.5.0;

import "./ISeller.sol";

contract Seller is ISeller{
    address payable public seller_address;
    bool public isExist;
   

    constructor(address payable _beneficiary) public {
        seller_address = _beneficiary;
        isExist = true;
    }

     event RegisterSeller(address seller);
}