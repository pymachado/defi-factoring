pragma solidity ^0.8.0;

import "../node_modules\@openzeppelin\contracts\utils\math\SafeMath.sol";
import "../node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol";

/**
 * @title TokenOfFactoring
 * @author Pedro Machado
 * @notice This contract can do the factorig process between diferents parts, 
 * routing the amount of payment deal for each parts and will can 
 * holder the profit accumulated and withdraw it for the factor person.
 * The contract storage the invoice's amount proportion that has been bought for at Factor. 
 * This system can counter the number of TokenOfFactoring relationated with one invoice, 
 * in a future one invoice can be sell to diferent factors.    
 * @dev Each input of finance data can be in wei unit.  
 */

contract TokenOfFactoring {
    using SafeMath for uint256;
    /**
     * @dev Assets to payment. 
     */
    IERC20 ierc20;

    /**
     * @dev Declare of parts to the deal.
     */
    address payable private seller;
    address payable private factor;
    address payable private buyer;

    /**
     * @notice Interest data.
     */
    uint256 private nonceInvoice;
    uint256 private amount;
    uint256 private reserve;
    uint256 private dayMaxOfSaleInvoice;
    uint256 private daysOutstandingFactoring; 
    uint256 private factoringFee;
    uint256 private feePerDay;
    string private description; 
    
    /**
     * @notice Validation data.
     * @dev actived[0]---> fundingEvent()
     *      actived[1]---> waitOfPay()
     */    
    bool[2] private activated;
    
    /**
     * @dev Event to describe one pay ejecuted.
     */
    event Payed (address indexed from, address indexed to, uint256 indexed amount);
    
    /**
     * @dev Declaration of constructor, it's describe the start value of the scope of the contract.
     */
    constructor(
        address payable _seller,
        address payable _factor, 
        address payable _buyer,
        uint256 _nonceInvoice,
        uint256 _amount,
        uint256 _reserve,
        uint256 _dayMaxOfSaleInvoice,
        uint256 _daysOutstandingFactoring,
        uint256 _factoringFee,
        uint256 _feePerDay
    ) {
        seller = _seller;
        factor = _factor;
        buyer = _buyer;
        nonceInvoice = _nonceInvoice;
        amount = _amount;
        reserve = _reserve;
        dayMaxOfSaleInvoice = SafeMath.add(SafeMath.mul(_dayMaxOfSaleInvoice, 1 minutes), now);
        daysOutstandingFactoring = SafeMath.add(SafeMath.mul(_daysOutstandingFactoring, 1 minutes), now);
        factoringFee = _factoringFee;
        feePerDay = _feePerDay;
        for (uint8 index = 0; index < activated.length; index++) {
            activated[index] = false;
        }
    }

    /**
     * @dev The function receive() can to Contract receive ethers from external accounts.
     */
    receive() external payable {}
 
    /**
     * @dev The modifier verify if the address to call the function is 
     * one of the address started on the constructor.
     */
    modifier onlySubject(address payable _subject, address payable _authorized) {
        require(_subject == _authorized, "You are not authorized to pay");
        _;
    }

    /**
     * @dev The modifier check if the function has been executed yet.
     */
    modifier onlyOnce(bool _activated) {
        require(! _activated, "That function has been executed or it's dependence has been executed");
        _;
    }


    /**
     * @dev This function do the pay to the seller from the factor, 
     * by amount equal to: initialFund = amount - reserve;
     * This function is called when the fundingEvent is executed.
     * This just can be executed once time. 
     * activated's index 0. 
     */
    function fundingEvent(address payable _factor, uint256 _value) public virtual onlySubject(_factor, factor) onlyOnce(activated[0]) {
        require( amount == _value, "The value that you try to transfer not match with deal");
        seller.transfer(SafeMath.sub(amount, reserve)); //initial funding
        activated[0] = true;
        emit Payed(factor, seller, _value);
    } 

    /**
     * @dev This function check the timme that Buyer pay the 
     * invoice and transfer to seller the value of reserve - interest. 
     * This function just can be executed once time and it's called by the Buyer. 
     * Its do that SC's balance will be equal to Factor's profit. 
     * activated's index 1.  
     */
    function waitOfPay(address payable _buyer, uint256 _value) public virtual onlySubject(_buyer, buyer) onlyOnce(! activated[0]) onlyOnce(activated[1]) {
        uint256 timestamp = now;
        require(timestamp <= dayMaxOfSaleInvoice, "Token has been expirated");
        require(amount == _value, "The amount not match with the value that you try to transfer");
        uint256 valueOfPay = reserve;
        factor.transfer(_value);
        if (timestamp <= daysOutstandingFactoring) { 
            valueOfPay = SafeMath.sub(valueOfPay, factoringFee);     
        }
        else if (timestamp > daysOutstandingFactoring && timestamp <= dayMaxOfSaleInvoice) { 
            valueOfPay = SafeMath.sub(valueOfPay, (SafeMath.add(factoringFee,  _accumulated(feePerDay))));
        }

        else revert();
        seller.transfer(valueOfPay);
        emit Payed (address(this), seller, valueOfPay);
        activated[1] = true;
    }

    /**
     * @dev This function can the factor withdraw his profit if function waitOfPay() has been executed.
     * Factor can withdraw once part of the profit or net profit.
     * The balance of SC is profit.
     */
    function withdrawProfit(address payable _factor, uint256 _amount) public virtual onlySubject(_factor, factor) onlyOnce(! activated[1]) {
        _withdraw(_amount, _factor);
    }

    /**
     * @dev The function below can Factor recovery his reserve just if function waitOfPay() it's NOT executed
     * and the moment that its called is major than of day max of sale invoice.   
     * Factor can withdraw once part of the reserve or net reserve.
     * The balance of SC is reserve.
     */

    function recovery(address payable _factor, uint256 _amount) public virtual onlySubject(_factor, factor) onlyOnce(activated[1]) {
        uint256 timestamp = now;
        require(timestamp > dayMaxOfSaleInvoice, "You can't receive anything couse still in force the range of pay");
        _withdraw(_amount, _factor);
    }

    /**
     * @dev This function show it the SC's balance. 
     */
    function balanceOf() public view virtual returns(uint256) {
        return address(this).balance;
    }

    /**
     * @notice The next functions are the public function to returns the scope of contract. 
     */

     /**
      * @dev Return seller address.
      */
    function _seller() public view virtual returns(address payable) { return seller;}
    
    /**
      * @dev Return factor address.
      */
    function _factor() public view virtual returns(address payable) { return factor;}
    
    /**
      * @dev Return buyer address.
      */
    function _buyer() public view virtual returns(address payable) { return buyer;}
    
    /**
      * @dev Return nonceInvoice.
      */
    function _nonceInvoice() public view virtual returns(uint256) { return nonceInvoice;}
    
    /**
      * @dev Return amount.
      */  
    function _amount() public view virtual returns(uint256) { return amount;}
    
    /**
      * @dev Return reserve.
      */
    function _reserve() public view virtual returns(uint256) { return reserve;}
    
    /**
      * @dev Return factoringFee.
      */
    function _factoringFee() public view virtual returns(uint256) { return factoringFee;}
    
    /**
      * @dev Return feePerDay.
      */
    function _feePerDay() public view virtual returns(uint256) { return feePerDay;}
    
    /**
      * @dev Return daysOutstandingFactoring.
      */
    function _daysOutstandingFactoring() public view virtual returns(uint256) { return daysOutstandingFactoring;}
    
    /**
      * @dev Return dayMaxOfSaleInvoice.
      */
    function _dayMaxOfSaleInvoice() public view virtual returns(uint256) { return dayMaxOfSaleInvoice;}
    
    /**
      * @dev Return description.
      */
    function _description() public view virtual returns(string memory) { return description;}
    
    /**
      * @dev Return activated.
      */
    function _activated(uint8 _index) public view virtual returns(bool) { return activated[_index];}

    /**
     * @dev The function below can to Factor withdraw once part of the balance or net balance of contract. 
     * Can be are two opctions:
     * 1- reserve
     * 2- profit 
     */
    function _withdraw(uint256 _amount, address payable _factor) private onlySubject(_factor, factor) {
        require(_amount <= address(this).balance);
        _factor.transfer(_amount);
    }

    /**
     * @dev This function return the value calculated feePerDay's accumulated 
     * from one seconds later of the day outstanding factoring to less than or 
     * iqual the maximumm day of seller invoice.   
     */
    function _accumulated(uint256 _feePerDay) private view returns(uint256) {
        uint256 daysPast = SafeMath.sub(now, daysOutstandingFactoring); 
        return SafeMath.mul(daysPast, _feePerDay);
    }
}