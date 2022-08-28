// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PriceConverter.sol";
import "hardhat/console.sol";

contract Weatherance is Ownable {
    using Converter for uint256;
    
    uint256 public constant SETTLEMENT_MULTIPLIER = 3;

    uint256 public constant MINIMUM_PREMIUM = 1e17;

    uint8 public constant TEMPERATURE_THRESHOLD = 40;

    mapping(address => bool) private activeInsurances;
    Insurance[] private insurances;
    AggregatorV3Interface public priceFeed;

    struct Insurance {
        address insuree;
        Temperature temperature;
        uint256 premium;
    }

    struct Temperature {
        uint8 day1;
        uint8 day2;
        uint8 day3;
        uint8 day4;
        uint8 day5;
    }

    event SettlementPaid(uint256 _amount, address _to);

    constructor(address priceFeedAddress) payable {
        console.log(
            "Deploying a Weatherance contract with initial balance of %s and owned by %s",
            msg.value,
            msg.sender
        );
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function createInsurance(
        address _insuree,
        uint256 _premium,
        uint8 _day1,
        uint8 _day2,
        uint8 _day3,
        uint8 _day4,
        uint8 _day5
    ) private pure returns (Insurance memory) {
        Temperature memory temperature;
        temperature.day1 = _day1;
        temperature.day2 = _day2;
        temperature.day3 = _day3;
        temperature.day4 = _day4;
        temperature.day5 = _day5;

        Insurance memory newInsurance;
        newInsurance.insuree = _insuree;
        newInsurance.premium = _premium;
        newInsurance.temperature = temperature;

        return newInsurance;
    }

    function buyInsurance() public payable {
        address payable _insuree = payable(msg.sender);
        require(
            activeInsurances[_insuree] == false,
            "Client already has an active policy"
        );
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_PREMIUM,
            "Premium value is too low"
        );

        Insurance memory newInsurance = createInsurance(
            _insuree,
            msg.value,
            0,
            0,
            0,
            0,
            0
        );

        activeInsurances[_insuree] = true;
        insurances.push(newInsurance);
        console.log(
            "Adding a new insurance: %s with premium of: %s",
            newInsurance.insuree,
            newInsurance.premium
        );
    }

    function updateTemperature(uint8 _newTemperature) public payable onlyOwner {
        console.log("Updating temperature with value of: %s", _newTemperature);
        for (uint256 i = 0; i < insurances.length; i++) {
            Insurance memory insurance = shiftTemperatures(
                insurances[i],
                _newTemperature
            );

            if (shouldPaySettlement(insurance)) {
                paySettlement(insurance);
                activeInsurances[insurance.insuree] = false;
                remove(i);
            } else {
                insurances[i] = insurance;
            }
        }
    }

    function shiftTemperatures(
        Insurance memory _insurance,
        uint8 _newTemperature
    ) private pure returns (Insurance memory) {
        _insurance.temperature.day1 = _insurance.temperature.day2;
        _insurance.temperature.day2 = _insurance.temperature.day3;
        _insurance.temperature.day3 = _insurance.temperature.day4;
        _insurance.temperature.day4 = _insurance.temperature.day5;
        _insurance.temperature.day5 = _newTemperature;
        return _insurance;
    }

    function shouldPaySettlement(Insurance memory _insurance)
        private
        pure
        returns (bool)
    {
        bool isMoreThanThreshold = _insurance.temperature.day1 >=
            TEMPERATURE_THRESHOLD &&
            _insurance.temperature.day2 >= TEMPERATURE_THRESHOLD &&
            _insurance.temperature.day3 >= TEMPERATURE_THRESHOLD &&
            _insurance.temperature.day4 >= TEMPERATURE_THRESHOLD &&
            _insurance.temperature.day5 >= TEMPERATURE_THRESHOLD;

        return isMoreThanThreshold;
    }

    function paySettlement(Insurance memory _insurance)
        public
        payable
        onlyOwner
    {
        console.log("About to pay settlement to %s", _insurance.insuree);
        uint256 settlementToPay = SETTLEMENT_MULTIPLIER * _insurance.premium;
        address addressToPay = _insurance.insuree;

        (bool sent, ) = addressToPay.call{value: settlementToPay}("");
        require(sent, "Failed to send Ether");
        console.log("Sent %s wei to %s", settlementToPay, addressToPay);

        emit SettlementPaid(settlementToPay, addressToPay);
    }

    function remove(uint256 _index) private {
        require(_index < insurances.length, "index out of bound");
        for (uint256 i = _index; i < insurances.length - 1; i++) {
            insurances[i] = insurances[i + 1];
        }
        insurances.pop();
    }
}
