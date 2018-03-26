import React from 'react';

export default class Game extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.state;
    var getMoves = this.getMoves.bind(this);
    this.props.channel.on("update", state => {
       this.setState(state)
    });
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

  render() {
      this.getMoves();
    return (
      <div>
        <h4>
          Turn: {this.state.turn}
        </h4>
        <div className="tiles">
            {this.state.tiles.map((v, i) => <Tile key={i} id={i} king={(v == null) ? false : v.king} player={(v == null) ? null : v.player } />)}
        </div>
        <div className="clear" /><br />
      </div>
    )
  }

}

function Tile(params) {
  var color = (params.player === 0 ? "red" : params.player === 1 ? "black" : "white");
  var piece = (params.player != null ? "piece" : "");
  var label = (params.king) ? "K" : "\u00A0"
  if ( Math.floor(((2 * params.id) / 8)) % 2 === 0 ) {
  return (
      <span>
      <div className="tile">&nbsp;</div>
      <div className="tile">
        <div id={"tile-" + params.id} className={piece} style={{backgroundColor: color}}>
          {label}
        </div>
      </div>
      </span>
    )
  } else {
  return (
      <span>
      <div className="tile">
        <div id={"tile-" + params.id} className={piece} style={{backgroundColor: color}}>
            {label}
        </div>
      </div>
      <div className="tile">&nbsp;</div>
      </span>
    )
  }
}