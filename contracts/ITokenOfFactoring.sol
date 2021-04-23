pragma solidity ^0.8.0;

/**
 * @title ITokenOfFactoring
 * @author Pedro Machado
 * @notice This code represents the TokenOfFactoring's interface. 
 */
interface ITokenOfFactoring {
    /**
     * @dev Return address seller from token of factoring.
     */
    function _seller() external view returns(address); 
    
    /**
     * @dev Return address factor from token of factoring.
     */
    function _factor() external view returns(address);

    /**
     * @dev Return address buyer from token of factoring.
     */
    function _buyer() external view returns(address);

    /**
     * @dev Return nonceInvoice from token of factoring.
     */
    function _nonceInvoice() external view returns(uint256);

    /**
     * @dev Return amount from token of factoring.
     */
    function _amount() external view returns(uint256);
    
    /**
     * @dev Return Factor's reserve from token of factoring.
     */
    function _reserve() external view returns(uint256);  
    
    /**
     * @dev Return dayMaxOfSaleInvoice from token of factoring.
     */
    function _dayMaxOfSaleInvoice() external view returns(uint256);

    /**
     * @dev Return daysOutstandingFactoring from token of factoring.
     */
    function _daysOutstandingFactoring() external view returns(uint256); 
    
    /**
     * @dev Return factoringFee from token of factoring.
     */
    function _factoringFee() external view returns(uint256);

    /**
     * @dev Return feePerDay from token of factoring.
     */
    function _feePerDay() external view returns(uint256);
    
    /**
     * @dev Return description from token of factoring.
     */
    function _description() external view returns(string memory);

    /**
     * @dev Return activated[] flag from token of factoring.
     */
    function _activated(uint8 _index) external view returns(bool);
    
    /**
     * @dev Call Token's fundingEvent() function, from token of factoring. 
     * Just Token's Factor can do it.
     */
    function fundingEvent(address payable _factor, uint256 _value) external;   
        
    /**
     * @dev Call Token's waitOfPay() function, from token of factoring. 
     * Just Token's Buyer can do it.
     */
    function waitOfPay(address payable _buyer, uint256 _value) external;
        
    /**
     * @dev Call Token's withdrawProfit() function, from token of factoring. 
     * Just Token's Factor can do it.
     */
    function withdrawProfit(address payable _factor, uint256 _amount) external;

    /**
     * @dev Call Token's recovery() function, from token of factoring. 
     * Just Token's Factor can do it.
     */
    function recovery(address payable _factor, uint256 _amount) external;
    
}