import React from 'react';

import Konva from "konva";
import { render } from "react-dom";
import { Stage, Layer, Rect, Circle } from "react-konva";

const tileWidth = 40;
const checkerBorder = 10;

export default class Game extends React.Component {
  constructor(props) {
    super(props);
    this.props = props;
    this.state = this.props.state;

    this.handleClick = this.handleClick.bind(this);
    this.play = this.play.bind(this);
    this.move = this.move.bind(this);

    console.log(this.state);

    var getMoves = this.getMoves.bind(this);
    this.props.channel.on("update", state => {
       this.setState(state)
    });
  }

  handleClick(event){
  	console.log(this.state);
  	console.log(event.target.attrs.index);
  }

  getMoves() {
    this.props.channel.push("valid_moves", {pending_piece: this.state.pending_piece}).receive("ok", state => {
      return state;
    });
  }

  move() {
    this.props.channel.push("move", {pending_piece: this.state.pending_piece}).receive("ok", state => {
        console.info(this.state.pending_piece);
    });
  }

  play() {
    this.props.channel.push("play", {}).receive("ok", state => {
        console.info("attempting to join as player");
    });
  }

  reset() {
  	this.setState({"pending_piece":null});
  }
	
	render() {
		const joinUI = (
			<div>
				<button
					onClick={this.play}>
					Join Game
				</button>
				<button
					onClick={null}>
					Back to Menu
				</button>
			</div>
		);

		const spectateUI = (
			<div>
				<button
					onClick={null}>
					Back to Menu
				</button>
			</div>
		);

		const waitUI = (
			<div>
				<button
					onClick={null}>
					Back to Menu
				</button>
				<h7> Waiting on players to join</h7>
			</div>
		);

		const playUI = (
			<div>
				<button
					onClick={this.move}>
					Submit
				</button>
				<button
					onClick={this.reset}>
					Reset
				</button>
				<button
					onClick={null}>
					Back to Menu
				</button>
				<button>Concede</button>
			</div>
		);

		const pendingTurnUI = (
			<div>
				<button>Back to Menu</button>
				<button>Concede</button>
			</div>
		); 	

  	var buttonsDiv;
  	var currentUser = document.getElementsByTagName('meta').user_email.content;

  	switch(this.state.players.indexOf(currentUser)){
  		default:
  			buttonsDiv = spectateUI;
  			break;
  		// not player of game
  		case -1:
  			// open spot available
  			if(this.state.players.length < 2){
  				buttonsDiv = joinUI;
  			}
  			// spectate
  			else {
  				buttonsDiv = spectateUI;
  			}
  			break;
  		// player1
  		case 0:
  			// waiting on players
  			if(this.state.players.length < 2){
  				buttonsDiv = waitUI;
  			}
  			// player 1 turn
  			else if(this.state.turn == 0){
  				buttonsDiv = playUI;
  			}
  			// player 2 turn
  			else {
  				buttonsDiv = pendingTurnUI;
  			}
  			break;
  		// player2
  		case 1:
  			// waiting on players
  			if(this.state.players.length < 2){
  				buttonsDiv = waitUI;
  			}
  			// player 1 turn
  			if(this.state.turn == 0){
  				buttonsDiv = pendingTurnUI;
  			}
  			// player 2 turn
  			else {
  				buttonsDiv = playUI;
  			}
  			break;
  	}
    
    return (
  		<div>
  			<h4>
		      {currentUser == this.state.players[this.state.turn] ? "Your turn" : "Player 2's turn"}
		    </h4>
		    {buttonsDiv}
	  		<Stage width={window.innerWidth} height={window.innerHeight}>
	        <Layer>
	          <Board />
	          <Checkers 
	          	tiles={this.state.tiles} 
	          	onClick={this.handleClick}
	          />
	        </Layer>
	      </Stage>
      </div>
  	); 
  }
}

function getPieceCoordinates(index) {
	var row = Math.floor(index / 4);
	
	if(row % 2 === 0){
		index = (index * 2) + 1;
	}
	else {
		index = index * 2;
	}

	var col = index % 8;

	return ([col * tileWidth, row * tileWidth]);
}

function Tile(tile) {
	var col = tile.index % 8;
	var row = Math.floor( tile.index / 8 );

	if(row % 2 === 0){
		var color = (tile.index % 2) === 0 ? "black" : "red";
	}
	else {
		var color = (tile.index % 2) === 0 ? "red" : "black";
	}

	return(
		<Rect
			key={tile.index}
			x={row * tileWidth}
			y={col * tileWidth}
		  width={tileWidth}
		  height={tileWidth}
		  fill={color}
		/>
	);
}

function Checker(checker) {
	var coor = getPieceCoordinates(checker.index);
	var color = checker.player == 0 ? "white" : "black";
	var checkerWidth = tileWidth - checkerBorder;

	return(
		<Circle
			index={checker.index}
			x={coor[0] + (tileWidth/2)}
			y={coor[1] + (tileWidth/2)}
			width={checkerWidth}
		  height={checkerWidth}
		  fill={color}
		  stroke={"gray"}
		  onClick={checker.onClick}
		 />
	);
}

class Board extends React.Component {
	render(){
  	var list = [];
		for (var i = 0; i <= 63; i++) {
		    list.push(i);
		}

		return(
			list.map((x, index) => 
				<Tile
					key={index} 
					index={x} 
				/>)
		);
	}
}

class Checkers extends React.Component {
	constructor(props) {
		super(props);
		this.state = this.props;
	}

	render(){
		var checkers = this.state.tiles.slice();

		return(
			checkers.map((checker, index) => 
			checker == null ? null :
			<Checker 
				key={index}
				index={index}
				player={checker.player} 
				pending_move={checker.pending_move}
				king={checker.king}
				onClick={this.state.onClick}
			/>)
		);
	}
}