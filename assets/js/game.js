import React from 'react';

import Konva from "konva";
import { render } from "react-dom";
import { Stage, Layer, Rect, Circle } from "react-konva";

const tileWidth = 40;
const checkerBorder = 10;
const currentUser = document.getElementsByTagName('meta').user_email.content;

export default class Game extends React.Component {
  constructor(props) {
    super(props);
    this.props = props;
    this.state = this.props.state;

    this.handleCheckerClick = this.handleCheckerClick.bind(this);
    this.handleHighlightClick = this.handleHighlightClick.bind(this);
    this.play = this.play.bind(this);
    this.move = this.move.bind(this);
    this.reset = this.reset.bind(this);
    this.disconnect = this.disconnect.bind(this);
    this.getMoves = this.getMoves.bind(this);
    this.getMoveDelay = this.getMoveDelay.bind(this);

    this.state = Object.assign(this.state, {loading: true}, {selectedChecker: -1}, {jumped: []});

    var getMoves = this.getMoves.bind(this);
    this.props.channel.on("update", state => {
       this.setState(state);
       console.log("ding");
       this.reset();
    });

    var caller = this;
		this.getMoves(function(x) { 
			caller.setState(Object.assign({}, x, {loading: false}));
		});
  }

  componentWillUnmount(){
  	this.reset();
  }

  handleCheckerClick(event){
		var checkerIndex = event.target.attrs.index;
		if(checkerIndex === this.state.selectedChecker){
			this.reset();
		}
		else{
			this.setState({selectedChecker: checkerIndex});
		}
  }

  handleHighlightClick(event){
		var checkerIndex = event.target.attrs.index;
		var pend = this.state.pending_piece === null ? [this.state.selectedChecker] : this.state.pending_piece;
		pend.push(parseInt(event.target.attrs.index));

		var options = this.state.moves[this.state.selectedChecker];
		var key = Object.keys(options).indexOf(checkerIndex);
		var deletedCheckerKey = Object.keys(options)[key];
		var deletedChecker = options[deletedCheckerKey];

		var jumped = this.state.jumped !== null ? this.state.jumped : null;
		if(deletedChecker !== null){
			jumped.push(deletedChecker);
		}
		this.setState({selectedChecker: checkerIndex, pending_piece: pend, loading: true, jumped: jumped});
		var caller = this;
		this.getMoves(function(x) { 
			caller.setState(Object.assign({}, x, {loading: false}));
		});
	}

  getMoves(func) {
  	if(this.state.pending_piece !== null){
  		console.log(this.state.pending_piece);
  		var moves = this.state.pending_piece.slice()
	  	var last = moves.pop();
	  	console.log(this.state.pending_piece);

	  	var movesTamper = [];
	  	var obj = {};
	  	obj[last] = {};
	  	movesTamper.push(obj)

	  	console.log(movesTamper[0], "tamp");

	  	if(last < 4 || last > 27){
	  		func({moves: movesTamper[0]});
	  	}else {
	  		this.props.channel.push("valid_moves", {pending_piece: this.state.pending_piece}).receive("ok", state => {
		      func({moves: state});
		    });
	  	}
	  }
	 	else {
			this.props.channel.push("valid_moves", {pending_piece: this.state.pending_piece}).receive("ok", state => {
      	func({moves: state});
    	});
	 	}
  }

  getMoveDelay(){
		var caller = this;
		this.getMoves(function(x) { 
			caller.setState(Object.assign({}, x, {loading: false}));
		});
	}

  move() {
    this.props.channel.push("move", {pending_piece: this.state.pending_piece}).receive("ok", state => {
        console.info(this.state.pending_piece);
    });
  }

  play() {
    var authEndpoint = "/auth/google";
    var channel = this.props.channel.push("play");
    channel.receive("ok", state => {
        console.info("attempting to join as player");
        return;
    });
    channel.receive("error", _ => {
        window.location.href = authEndpoint;
    });
  }

  reset() {
  	this.setState({pending_piece: null, selectedChecker: -1, loading: true, jumped: []}, 
  		this.getMoveDelay
    );
  }

  disconnect() {
  	location.reload();
  }
	
	render() {
		console.log(this.state.pending_piece);
    var currentUserIdx = this.state.players.indexOf(currentUser);
    var isPlayerTurn = this.state.turn % 2 === currentUserIdx;
    var playerColor = null;
    if (currentUserIdx === 0) {
        playerColor = "white";
    } else if (currentUserIdx === 1) {
        playerColor = "black"
    }
		if(this.state.loading == true){
			return(
				<div>
					<h5> Loading... </h5>
				</div>
			);
		}

		const waitUI = (
			<div>
                {this.state.players.length < 2 && currentUserIdx === -1 ?
                    <button onClick={this.play}>Play</button>
                : ""}
				<button
					onClick={this.disconnect}>
					Back to Menu
				</button>
                <h6>{this.state.players.length < 2 ? "Waiting for another player to join" : ""}</h6>
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
					onClick={this.disconnect}>
					Back to Menu
				</button>
				<button>Concede</button>
                <h6>It's your turn ({playerColor})</h6>
			</div>
		);

		const pendingTurnUI = (
			<div>
				<button
					onClick={this.disconnect}>
					Back to Menu
				</button>
				<button>Concede</button>
                <h6>Waiting on opponent</h6>
			</div>
		); 	

  	var buttonsDiv;
  	var checkerClicker = null;

    if (this.state.players.length < 2 || currentUserIdx === -1) {
        buttonsDiv = waitUI;
    } else if (isPlayerTurn) {
        buttonsDiv = playUI;
        checkerClicker = this.handleCheckerClick;
    } else {
        buttonsDiv = pendingTurnUI;
    }

    var theta = 0;
		var xdis = 0;
		var ydis = 0;
		if(currentUserIdx === 0){
			theta = 180;
			xdis = tileWidth * 8;
			ydis = tileWidth * 8;
		}
    
    var highlighted = null;
		if(this.state.selectedChecker !== -1){
			var key = Object.keys(this.state.moves)[0];
			var tiles = this.state.pending_piece !== null ? this.state.moves[key]: this.state.moves[this.state.selectedChecker];
			highlighted = (
				<HighlightedTiles
					start={this.state.selectedChecker}
        	tiles={tiles}
        	onClick={this.handleHighlightClick}
        />
			)
		}

    var checkers = this.state.tiles.slice();

    if(this.state.pending_piece !== null && this.state.pending_piece.length > 1){
        var startIndex = this.state.pending_piece[0];
        var endIndex = this.state.pending_piece[this.state.pending_piece.length -1];

        var start = this.state.tiles[startIndex];
        var end = this.state.tiles[endIndex];

        checkers[startIndex] = end;
        checkers[endIndex] = start;

        var i;
        for(i = 0; i < this.state.jumped.length; i++){
            checkers[this.state.jumped[i]] = null;
        }
    }

    return (
  		<div>
  			<h4>
		      {currentUser === this.state.players[this.state.turn % 2] ? "Your turn" : "Player " + ((this.state.turn % 2) + 1)  + "'s turn"}
		    </h4>
		    {buttonsDiv}
	  		<Stage 
	  			x={xdis}
	  			y={ydis}
	  			rotation={theta}
	  			width={window.innerWidth} 
	  			height={window.innerHeight} >
	        <Layer>
	          <Board />
	          {highlighted}
	          <Checkers 
	          	tiles={checkers} 
	          	currentPlayer={currentUserIdx}
	          	selected={this.state.selectedChecker}
	          	onClick={checkerClicker}
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

function HighlightedTile(tile){
	let index;

	var row = Math.floor(tile.index / 4);
	
	if(row % 2 === 0){
		index = (tile.index * 2) + 1;
	}
	else {
		index = tile.index * 2;
	}

	var col = index % 8;

	return(
		<Rect
			index={tile.index}
			key={tile.index}
			x={col * tileWidth}
			y={row * tileWidth}
		  width={tileWidth}
		  height={tileWidth}
		  fill={tile.color}
		  opacity={0.75}
		  onClick={tile.onClick}
		/>
	);
}

function Checker(checker) {
	var coor = getPieceCoordinates(checker.index);
	var color = checker.player == 0 ? "white" : "black";
	var checkerWidth = tileWidth - checkerBorder;

	var borderColor = checker.king ? "yellow" : "gray";

	return(
		<Circle
			index={checker.index}
			x={coor[0] + (tileWidth/2)}
			y={coor[1] + (tileWidth/2)}
			width={checkerWidth}
		  height={checkerWidth}
		  fill={color}
		  stroke={borderColor}
		  strokeWidth={5}
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
		var checkers = this.props.tiles.slice();

		return(
			checkers.map((checker, index) => 
			checker == null ? null :
			<Checker 
				key={index}
				index={index}
				player={checker.player} 
				king={checker.king}
				onClick={(this.props.currentPlayer === checker.player && (this.props.selected === -1 || this.props.selected === index)) ? this.props.onClick : null}
			/>)
		);
	}
}

class HighlightedTiles extends React.Component {
	constructor(props) {
		super(props);
		this.state = this.props;
	}

	render(){
		var tiles = Object.keys(this.props.tiles);

		var hTile = tiles.map((tile, index) => 
		tile == null ? null :
		<HighlightedTile 
			key={index}
			index={tile}
			color={"green"}
			onClick={this.props.onClick}
		/>);

		hTile.push(
			<HighlightedTile
				key={-1}
				index={this.props.start}
				color={"blue"}
			/>);

		return hTile;
	}
}