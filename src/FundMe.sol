// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./PriceConverter.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMe {

   address public immutable i_owner;

   constructor(address priceFeed){
      i_owner = msg.sender;
      s_priceFeed =AggregatorV3Interface(priceFeed);
   }

   modifier onlyOwner(){
      require(msg.sender == i_owner);
      _;
   }

using PriceConverter for uint256;
     AggregatorV3Interface private s_priceFeed;
    uint256 public constant MINIMUMUSD = 5e18;
    address [] private  s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;



   function fund() public payable{
      require (msg.value.getConversionRate(s_priceFeed) >= MINIMUMUSD, "didn't send enough ether");
   
      s_funders.push(msg.sender);
       s_addressToAmountFunded[msg.sender]  += msg.value;

   }

   //  function getPrice() public view returns (uint256){
   //       // Address  0x694AA1769357215DE4FAC081bf1f309aDC325306
   //       AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
   //      (,int256 price,,,)= priceFeed.latestRoundData();  // function comes from aggregatorV3Interface
   //    return uint256 (price * 1e10);




   //  }

   // function getConversionRate(uint256 ethAmount) public view returns (uint256){
   //    uint256 ethPrice = getPrice();
   //    // solidity values return a lot of decimals (18) hence the need for conversions
   //    uint256 ethAmountInUSD = (ethAmount * ethPrice)/ 1e18;
   //    return ethAmountInUSD;



   // }
function cheaperWithdraw() public onlyOwner{
   uint256 fundersLength = s_funders.length; // to read the array once now from memory

for(uint256 funderIndex = 0; funderIndex<fundersLength;funderIndex++){
    address funder = s_funders[funderIndex];
              s_addressToAmountFunded[funder]  = 0;

}
  s_funders = new address[](0);
         (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
            require(callSuccess,"Call failed");
}






   function withdraw () public onlyOwner {
         for(uint256 i = 0; i < s_funders.length; i++){
                 address funder = s_funders[i];
              s_addressToAmountFunded[funder]  = 0;
         }
         s_funders = new address[](0);
         (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
            require(callSuccess,"Call failed");
   }

   function getVersion()public view returns (uint256){
      return s_priceFeed.version();
   }



//**View functions */


function getAddressToAmountFunded(address fundingAddress) external view returns(uint256 ){
   return s_addressToAmountFunded[fundingAddress];

}


function getFunder(uint256 index) external view returns (address){
      return s_funders[index];
}

function getOwner () external view returns (address){
   return i_owner;
}



















}