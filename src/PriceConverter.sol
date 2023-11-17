//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
library PriceConverter{

    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256){
         // Address  0x694AA1769357215DE4FAC081bf1f309aDC325306
         
        (,int256 price,,,)= priceFeed.latestRoundData();  // function comes from aggregatorV3Interface
      return uint256 (price * 1e10);




    }

   function getConversionRate(uint256 ethAmount , AggregatorV3Interface priceFeed) internal view returns (uint256){
      uint256 ethPrice = getPrice(priceFeed);
      // solidity values return a lot of decimals (18) hence the need for conversions
      uint256 ethAmountInUSD = (ethAmount * ethPrice)/ 1e18;
      return ethAmountInUSD;



   }




}