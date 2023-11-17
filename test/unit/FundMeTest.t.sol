//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract  FundMeTest is Test{
    
FundMe fundme;

address USER = makeAddr("user");
uint256 constant SEND_VALUE = 0.1 ether;
uint256 constant STARTING_BALANCE = 10 ether;
uint256 constant GAS_PRICE =1;



    function setUp()external{
       DeployFundMe  deployFundme = new DeployFundMe();
       fundme = deployFundme.run();
       vm.deal(USER,STARTING_BALANCE);
    }
    
    function testMinimumDollarIsFive()public{
        assertEq(fundme.MINIMUMUSD(),5e18);

    }

    function testOwnerISMsgSender() public {
        
        assertEq(fundme.i_owner(), msg.sender);

    }

    function testPriceFeedVersion() public{
        uint256 version = fundme.getVersion();
        assertEq(version,4);
    }


function testFundFailsWithoutEnoughETH() public{
    vm.expectRevert(); // the next line of code should produce a revert
    fundme.fund();
}

function testFundUpdatesFundedDataStructure() public{
    vm.prank(USER); //The Next TX will be sent by USER
    fundme.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
    assertEq(amountFunded,SEND_VALUE);

}

function testAddsFunderToArrayOfFunders() public{
     vm.prank(USER); //The Next TX will be sent by USER
    fundme.fund{value: SEND_VALUE}();

    address funder = fundme.getFunder(0);
    assertEq(funder,USER);
}
 
// a modifier that handles the funding logic for testing
 modifier funded(){
  vm.prank(USER);
  fundme.fund{value: SEND_VALUE}();
  _;
 }

function testOnlyOwnerCanWithdraw () public funded {
      
    vm.expectRevert();
    vm.prank(USER);
    fundme.withdraw();


}

function testWithdrawAWithASingleFunder() public funded{
    //Arrange
   uint256 startingOwnerBalance = fundme.getOwner().balance;
   uint256 startingFundMeBalance = address(fundme).balance;


    //Act
    uint256 gasStart = gasleft(); //built-in function in solidity
    vm.txGasPrice(GAS_PRICE);
    vm.prank(fundme.getOwner());
    fundme.withdraw();

    
    //Assert
    uint256 endingOwnerBalance = fundme.getOwner().balance;
    uint256 endingFundMeBalance = address(fundme).balance;
    assertEq(endingFundMeBalance,0);
    assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

  }

  

  function testWithdrawFromMultipleFunders () public funded {
       uint160 numberOfFunders = 10;
       uint160 startingFunderIndex = 1;

       for(uint160 i = startingFunderIndex; i<numberOfFunders; i++){
          hoax(address(i), SEND_VALUE);
       }
       uint256 startingOwnerBalance = fundme.getOwner().balance;
       uint256 startingFundMeBalance = address(fundme).balance;
       
       vm.startPrank(fundme.getOwner());
       fundme.withdraw();
       vm.stopPrank();

       assert(address(fundme).balance == 0);
       assert(startingFundMeBalance + startingOwnerBalance == fundme.getOwner().balance);
  }
}

