pragma solidity ^0.4.24;

/*
**	스포츠 경기에 내기하는 컨트랙트이다.
**	사용자는 컨트랙트로 승팀을 선택해 이더를 송금한다.
**	컨트랙트 소유자(관리자)는 경기 결과를 입력하고 배당금을 분배한다.
**
**	컨트랙트는 팀별로 송금받은 계좌와 금액을 기록한다.
**	배당금은 수수료를 제하고 남은 금액을 분배한다.
**	승자는 배팅한 금액과 이긴 팀에 배팅된 총 금액의 비율에 따라 배당금을 받는다.
**	
**	관리자는 배팅 제한시간을 설정할 수 있다.
**	사용자는 배팅 제한시간 이전에만 배팅할 수 있다.
*/

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Wager is Ownable{

	using SafeMath for uint;

	uint 	fee_percent = 100 ;	// 컨트랙트 소유자가 가져가는 수수료율
	uint 	denominator = 1000;	// 천분률 
//	enum  	game_result { Win, Lose, Draw }	// 홈팀 기준 경기 결과의 경우의 수
	uint constant WIN = 0;
	uint constant LOSE = 1;
	uint constant DRAW = 2;

//	uint 	time_limit;
	
	// 베팅한 사람 명단
	// 아래 mapping에서 모든 key 값을 가져올 수 있다면 필요 없다.
	address[] betterForWin;
	address[] betterForLose;
	address[] betterForDraw;

	// 베팅한 사람이 얼마나 베팅했는지 기록
	mapping (address => uint) bettingForWin;
	mapping (address => uint) bettingForLose;
	mapping (address => uint) bettingForDraw;

	// for trubleshoot INVALID OPCODE
	bool flagToFunctionBetting = false;

	constructor(uint _fee_percent, uint _denominator) public {
		owner = msg.sender;
		fee_percent = _fee_percent;
		denominator = _denominator;
	}

	// 사용자가 배팅할 때 호출하는 함수이다.
	// 매개변수로 홈팀의 승패 여부를 받는다.
	function betting(uint _isWin) external payable{
		// 제한시간 전인 경우만 배팅할 수 있다.
//		require(now <= time_limit);

		flagToFunctionBetting = true;

		// SafeMath
		if(_isWin == WIN){
			betterForWin.push( msg.sender );
			bettingForWin[ msg.sender ] = bettingForWin[ msg.sender ].add( msg.value );
			return;
		}
		if(_isWin == LOSE){
			betterForLose.push(msg.sender);
			bettingForLose[ msg.sender ] = bettingForLose[ msg.sender ].add( msg.value );
			return;
		}
		if(_isWin == DRAW){
			betterForDraw.push(msg.sender);
			bettingForDraw[ msg.sender ] = bettingForDraw[ msg.sender ].add( msg.value );
			return;
		}

		// for trubbleshoot INVALID OPCODE
		revert("What??? is there another case WIN, LOSE, DRAW?");
	}

	// 배당금을 분배한다.
	function withdraw(uint _isWin) external onlyOwner{
		// 승팀의 베팅한 계좌별 베팅금액 비율을 구한다.
		// 비율에 따라 패팀의 금액 수수료를 제한 후 나눠 갖는다.

		// 1.xx % 만들기 위해 denominator 만큼 더해준다.
		// uint _ratio = (1 * denominator) + ratioForWinner(_isWin);
		// SafeMath
		uint _ratio = ratioForWinner(_isWin).add( denominator );
		//uint _reward_ratio = denominator.add( _ratio );
//		uint _ratio = 1100;

		uint 	i;	// for Loop
		address _winner;
		uint 	_reward;

		if(_isWin == WIN){
			for(i = 0; i < betterForWin.length ; i++){
				_winner = betterForWin[i];
		//		_reward = bettingForWin[ _winner ].mul( _ratio );	// 배팅한 금액 * 배당률
				_reward = _multiplyFraction(bettingForWin[ _winner ]
										   , _ratio
										   , denominator);

				require(_reward <= address(this).balance );
				_winner.transfer( _reward );
			}
		}
		if(_isWin == LOSE){
			for(i = 0; i < betterForLose.length ; i++){
				_winner = betterForLose[i];
		//		_reward = bettingForLose[ _winner ].mul( _ratio );	// 배팅한 금액 * 배당률
				_reward = _multiplyFraction(bettingForLose[ _winner ]
										   , _ratio
										   , denominator);

				require(_reward <= address(this).balance );
				_winner.transfer( _reward );
			}
		}
		if(_isWin == DRAW){
			for(i = 0; i < betterForDraw.length ; i++){
				_winner = betterForDraw[i];
		//		_reward = bettingForDraw[ _winner ].mul( _ratio );	// 배팅한 금액 * 배당률
				_reward = _multiplyFraction(bettingForDraw[ _winner ]
										   , _ratio
										   , denominator);

				require(_reward <= address(this).balance );
				_winner.transfer( _reward );
			}
		}


		// 분배 후 잔고를 모두 가져간다. fee 기본 값 = 10%
		owner.transfer(address(this).balance);
	}

	// 배당금의 총 합을 구한다.
	// INVALID OPCODE
	function totalWager(uint _isWin) public view returns(uint _result){
		// SafeMath

		uint i;	// for Loop

		// 이중에 Invalid OPCODE를 유발하는 녀석이 있다...
		if(_isWin == WIN){
			for(i = 0; i < betterForLose.length; i++){
				_result = _result.add( bettingForLose[ betterForLose[i] ] );
			}
			for(i = 0; i < betterForDraw.length; i++){
				_result = _result.add( bettingForDraw[ betterForDraw[i] ] );
			}
			// INVALID OPCODE
		//uint numberOfLosers;
//			numberOfLosers = betterForLose.length.add( betterForDraw.length );
//			for(i = 0; i < numberOfLosers; i++){
//				_result = _result.add( bettingForLose[ betterForLose[i] ] );
//				_result = _result.add( bettingForDraw[ betterForDraw[i] ] );
//			}
		}
		if(_isWin == LOSE){
			for(i = 0; i < betterForWin.length; i++){
				_result = _result.add( bettingForWin[ betterForWin[i] ] );
			}
			for(i = 0; i < betterForDraw.length; i++){
				_result = _result.add( bettingForDraw[ betterForDraw[i] ] );
			}
		}
		if(_isWin == DRAW){
			for(i = 0; i < betterForLose.length; i++){
				_result = _result.add( bettingForLose[ betterForLose[i] ] );
			}
			for(i = 0; i < betterForWin.length; i++){
				_result = _result.add( bettingForWin[ betterForWin[i] ] );
			}
		}

		uint _fee = _multiplyFraction(_result, fee_percent, denominator);
		_result = _result.sub( _fee );
		
		return _result;
	}

	// 배당율을 구한다.
	// 배당률은 진팀의 판돈 총합과 이긴팀의 판톤 총합의 비율이다.
	// 진팀 판돈 / 이긴팀 판돈
	// 분배할 때 배팅한 금액에 배당률을 곱해 지급한다.
	function ratioForWinner(uint _isWin) public view returns(uint){
		uint _totalReward = totalWager(_isWin);
		uint _totalWinnersCache = 0;

		uint i;
		if(_isWin == WIN){
			for(i = 0; i < betterForWin.length; i++){
				// SafeMath 
				_totalWinnersCache = _totalWinnersCache.add( bettingForWin[ betterForWin[i] ] );
			//	_totalWinnersCache += bettingForWin[ betterForWin[i] ];	
			}
		}
		if(_isWin == LOSE){
			for(i = 0; i < betterForLose.length; i++){
				_totalWinnersCache = _totalWinnersCache.add( bettingForLose[ betterForLose[i] ] );
			//	_totalWinnersCache += bettingForLose[ betterForLose[i] ];
			}
		}
		if(_isWin == DRAW){
			for(i = 0; i < betterForDraw.length; i++){
				_totalWinnersCache = _totalWinnersCache.add( bettingForDraw[ betterForDraw[i] ] );
			//	_totalWinnersCache += bettingForDraw[ betterForDraw[i] ];
			}
		}

		if(_totalWinnersCache <= 0 && flagToFunctionBetting)
			revert("Winner's budgit was gone!!!");	// for trubleshot to INVALID OPCODE
		else
			return _getRatio(_totalWinnersCache, _totalReward, denominator);
	}

	// TODO: 배팅 제한시간 설정

	// 수수료 계산(이자 계산법)
	// 수수료율에 따른 수수료가 얼만지 계산한다.
	// 곱하기를 나누기보다 먼저 계산해야한다.
	// https://www.bluebear.tech/posts/how-to-handle-decimals-and-percentages-in-solidity
	//
	// numerator	분자
	// denominator	분모
	// return feeAmount
	function _multiplyFraction(uint _number, uint _rate, uint _denominator) internal pure returns (uint){
		return _number.mul(_rate).div(_denominator);	// SafeMath
	//	return (_number * _rate) / _denominator;
	}

	// 비율을 구하는 함수
	// Solidity는 부동 소수점을 지원하지 않기 때문에 이 방법을 쓴다.
	// 원하는 부동 소수점 자릿수 만큼 분자에 먼저 곱한다.
	// 패팀의 판돈을 승팀의 판돈으로 나누어 승팀의 배당률을 구한다.
	// 
	// denominator(분모) : 백분률을 구하는 경우 100, 천분율 1000, 만분률 10000
	// return ratio
	function _getRatio(uint _winnerAmount, uint _loserAmount, uint _denominator) internal pure returns (uint){
		if(_winnerAmount != 0)
			return _loserAmount.mul(_denominator).div(_winnerAmount);	// SafeMath
		else
			return 0;
	//	return (_loserAmount * _denominator) / _winnerAmount;
	}
}
