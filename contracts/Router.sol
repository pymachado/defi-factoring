pragma solidity ^0.8.0;

import "../node_modules\@openzeppelin\contracts\access\Ownable.sol"
import "./TokenOfFactoring.sol";
import "./ITokenFactoring.sol"

/**
 * @title Router
 * @author Pedro Machado
 * @notice Reserva’s ERP can manager and controller the
 * inputs/outputs Tx from clients and routing the amount to recipients. 
 * The Router aim to SC Contract of Factoring’s address.     
 * @dev Each input of finance data can be in wei unit.  
*/

contract Router is Ownable {
    TokenOfFactoring private token;//Aim to interface.
    address[] private _tokenOfFactorings;//Count the number of tokens uploaded to blockchain.
    mapping (uint256 => address payable) public tokens;//Returns the token's address linked with his token's id. 
    mapping (uint => uint) public debts;//Returns wich tokens linkeding with one invoice. 

    /**
     *@dev The Router's constructor to initialized the contract. 
     */
    constructor() {}

    /**
     *@notice The next group of functions response to Router's scope. 
     *@dev This function is a factory of tokens. She make one TokenOfFactoring smart contract with each call,
     *getting the token's address , save it into an array and a mapping and upload to blockcahin. 
     *It's my favorite :)
     */
    function uploadDeal(
        address payable _factor, 
        address payable _buyer,
        uint256 _nonceInvoice,
        uint256 _amount,
        uint256 _reserve,
        uint256 _dayMaxOfSaleInvoice,
        uint256 _daysOutstandingFactoring,
        uint256 _factoringFee,
        uint256 _feePerDay) external {
            TokenOfFactoring tokenOfFactoring = new TokenOfFactoring(
                _msgSender(),       
                _factor, 
                _buyer,
                _nonceInvoice,
                _amount,
                _reserve,
                _dayMaxOfSaleInvoice,
                _daysOutstandingFactoring,
                _factoringFee,
                _feePerDay
            );
        _tokenOfFactorings.push(address(tokenOfFactoring));
        uint id = _tokenOfFactorings.length - 1;
        tokens[id] = address(tokenOfFactoring);
        debts[_nonceInvoice] = id;
    }

    /**
     *@dev Returns the number of tokens upload to blockchain
     */
    function getNumberOfTokens() external view returns(uint256) {
        return _tokenOfFactorings.length;
    }

    /**
     *@dev This function delete the Router contract from the blockchain.
     */
    function destroy() external onlyOwner() {
        selfdestruct(payable(owner()));
    }

    /**
     *@notice The next group of functions response to ITokenFactoring's Interface. 
     *@dev Declaration of function setters. The next group of functions change the state of blockchain,
     *calling one token's function to pay or witdraw.   
     */

     /**
      *@dev Call fundingEvent() function from the token that aim to id argument. 
      */
    function setFundingEvent(uint256 _id) external payable {
        token = ITokenFactoring(tokens[_id]);
        tokens[_id].transfer(msg.value);
        token.fundingEvent(_msgSender(), msg.value);
    }

    /**
      *@dev Call waitOfPay() function from the token that aim to id argument. 
      */
    function setWaitOfPay(uint256 _id) external payable {
        token = ITokenFactoring(tokens[_id]);
        tokens[_id].transfer(msg.value);
        token.waitOfPay(_msgSender(), msg.value);
    }

    /**
      *@dev Call withdrawProfit(_amount) function from the token that aim to id argument. 
      */
    function setWithdrawProfit(uint256 _id, uint256 _amount) external {
        token = ITokenFactoring(tokens[_id]);
        token.withdrawProfit(_msgSender(), _amount);
    }

    /**
      *@dev Call recovery(_amount) function from the token that aim to id argument. 
      */
    function setRecovery(uint256 _id, uint256 _amount) external {
        token = ITokenFactoring(tokens[_id]);
        token.recovery(_msgSender(), _amount);
    }

    /**
     *@dev Declaration of function getters. The next group of functions doesn't change the state of blockchain,
     *just call one token's function to know its state it.   
     */

    /**
     *@dev Returns function fundingEvent()'s state from one token that response to an id. 
     */  
    function getFundingEvent(uint256 _id) external returns(bool) {
        token = ITokenFactoring(tokens[_id]);
        return token._activated(0);
    }

    /**
     *@dev Returns function WaitOfPay()'s state from one token that response to an id. If the result is true, 
     *it means that contract has been paid.  
     */
    function getWaitOfPay(uint256 _id) external returns(bool) {
        token = ITokenFactoring(tokens[_id]);
        return token._activated(1);
    }

    /**
     *@dev Returns Seller from one token that response to an id.
     */
    function getSeller(uint256 _id) external returns(address) {
        token = ITokenFactoring(tokens[_id]);
        return token._seller();
    }

    /**
     *@dev Returns Factor from one token that response to an id.
     */
    function getFactor(uint256 _id) external returns(address) {
        token = ITokenFactoring(tokens[_id]);
        return token._factor();
    }

    /**
     *@dev Returns Buyer from one token that response to an id.
     */
    function getBuyer(uint256 _id) external returns(address) {
        token = ITokenFactoring(tokens[_id]);
        return token._buyer();
    }

    /**
     *@dev Returns nonceInvoice from one token that response to an id.
     */
    function getNonceInvoice(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._nonceInvoice();        
    }

    /**
     *@dev Returns Amount from one token that response to an id.
     */
    function getAmount(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._amount();
    }

    /**
     *@dev Returns reserve from one token that response to an id.
     */
    function getReserve(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._reserve();
    }

    /**
     *@dev Returns initial funding from one token that response to an id.
     */
    function getInitialFunding(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._amount() - token._reserve();
    }

    /**
     *@dev Returns daysOutstandingFactoring() from one token that response to an id.
     */
    function getDaysOutstandingFactoring(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._daysOutstandingFactoring();
    }

    /**
     *@dev Returns dayMaxOfSaleInvoice() from one token that response to an id.
     */
    function getDayMaxOfSaleInvoice(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._dayMaxOfSaleInvoice();
    }

    /**
     *@dev Returns factoringFee() from one token that response to an id.
     */
    function getFactoringFee(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._factoringFee();
    }

    /**
     *@dev Returns feePerDay() from one token that response to an id.
     */
    function getFeePerDay(uint256 _id) external returns(uint256) {
        token = ITokenFactoring(tokens[_id]);
        return token._feePerDay();
    }

    /**
     *@dev Returns description() from one token that response to an id.
     */
    function getDescription(uint _id) external returns(string memory) {
        token = ITokenFactoring(tokens[_id]);
        return token._description();
    }
    
    /**
     *@dev Returns balance of token that response to an id.
     */
    function getBalanceToken(uint _id) external view returns(uint256) {
        return address(tokens[_id]).balance;
    }   
}