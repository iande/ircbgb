
# line 1 "lib/ircbgb/message_parser.rl"
# RFC 1459 Message Parser to be processed by Ragel

# line 58 "lib/ircbgb/message_parser.rl"


module Ircbgb
  class MessageParser

    
# line 13 "lib/ircbgb/message_parser.rb"
class << self
	attr_accessor :_irc_message_parser_actions
	private :_irc_message_parser_actions, :_irc_message_parser_actions=
end
self._irc_message_parser_actions = [
	0, 1, 0, 1, 3, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 10, 1, 
	11, 1, 12, 1, 13, 1, 14, 2, 
	1, 11, 2, 2, 7, 2, 3, 10, 
	2, 4, 8, 2, 5, 6, 2, 7, 
	6, 2, 13, 12, 3, 0, 1, 11, 
	4, 2, 7, 5, 6
]

class << self
	attr_accessor :_irc_message_parser_key_offsets
	private :_irc_message_parser_key_offsets, :_irc_message_parser_key_offsets=
end
self._irc_message_parser_key_offsets = [
	0, 0, 7, 11, 12, 17, 21, 26, 
	30, 35, 39, 44, 48, 53, 57, 62, 
	66, 71, 75, 80, 84, 89, 93, 98, 
	102, 107, 111, 116, 120, 125, 129, 134, 
	138, 141, 144, 147, 157, 166, 173, 179, 
	185, 199, 204, 209, 220, 234, 243, 249, 
	263, 269, 276, 282, 289, 295, 302, 308, 
	315, 321, 328, 334, 341, 347, 354, 361, 
	368, 375, 382, 389, 396, 403, 410, 419, 
	426, 432, 440, 442, 445, 447, 450, 452, 
	455, 458, 459, 462, 463, 466, 467, 475, 
	483, 492, 501, 510, 517
]

class << self
	attr_accessor :_irc_message_parser_trans_keys
	private :_irc_message_parser_trans_keys, :_irc_message_parser_trans_keys=
end
self._irc_message_parser_trans_keys = [
	58, 48, 57, 65, 90, 97, 122, 13, 
	32, 48, 57, 10, 0, 10, 13, 32, 
	58, 0, 10, 13, 32, 0, 10, 13, 
	32, 58, 0, 10, 13, 32, 0, 10, 
	13, 32, 58, 0, 10, 13, 32, 0, 
	10, 13, 32, 58, 0, 10, 13, 32, 
	0, 10, 13, 32, 58, 0, 10, 13, 
	32, 0, 10, 13, 32, 58, 0, 10, 
	13, 32, 0, 10, 13, 32, 58, 0, 
	10, 13, 32, 0, 10, 13, 32, 58, 
	0, 10, 13, 32, 0, 10, 13, 32, 
	58, 0, 10, 13, 32, 0, 10, 13, 
	32, 58, 0, 10, 13, 32, 0, 10, 
	13, 32, 58, 0, 10, 13, 32, 0, 
	10, 13, 32, 58, 0, 10, 13, 32, 
	0, 10, 13, 32, 58, 0, 10, 13, 
	32, 0, 10, 13, 32, 58, 0, 10, 
	13, 32, 13, 32, 58, 0, 10, 13, 
	0, 10, 13, 48, 57, 65, 90, 91, 
	96, 97, 122, 123, 125, 32, 45, 46, 
	48, 57, 65, 90, 97, 122, 32, 48, 
	57, 65, 90, 97, 122, 13, 32, 65, 
	90, 97, 122, 48, 57, 65, 90, 97, 
	122, 32, 33, 45, 46, 48, 57, 65, 
	90, 91, 96, 97, 122, 123, 125, 0, 
	10, 13, 32, 64, 0, 10, 13, 32, 
	64, 48, 49, 57, 65, 70, 71, 90, 
	97, 102, 103, 122, 32, 45, 46, 58, 
	48, 57, 65, 70, 71, 90, 97, 102, 
	103, 122, 32, 45, 46, 48, 57, 65, 
	90, 97, 122, 48, 57, 65, 90, 97, 
	122, 32, 45, 46, 58, 48, 57, 65, 
	70, 71, 90, 97, 102, 103, 122, 48, 
	57, 65, 70, 97, 102, 58, 48, 57, 
	65, 70, 97, 102, 48, 57, 65, 70, 
	97, 102, 58, 48, 57, 65, 70, 97, 
	102, 48, 57, 65, 70, 97, 102, 58, 
	48, 57, 65, 70, 97, 102, 48, 57, 
	65, 70, 97, 102, 58, 48, 57, 65, 
	70, 97, 102, 48, 57, 65, 70, 97, 
	102, 58, 48, 57, 65, 70, 97, 102, 
	48, 57, 65, 70, 97, 102, 58, 48, 
	57, 65, 70, 97, 102, 48, 57, 65, 
	70, 97, 102, 32, 48, 57, 65, 70, 
	97, 102, 48, 49, 57, 65, 70, 97, 
	102, 58, 48, 57, 65, 70, 97, 102, 
	48, 49, 57, 65, 70, 97, 102, 58, 
	48, 57, 65, 70, 97, 102, 48, 49, 
	57, 65, 70, 97, 102, 58, 48, 57, 
	65, 70, 97, 102, 48, 49, 57, 65, 
	70, 97, 102, 58, 48, 57, 65, 70, 
	97, 102, 48, 70, 102, 49, 57, 65, 
	69, 97, 101, 58, 48, 57, 65, 70, 
	97, 102, 48, 57, 65, 70, 97, 102, 
	46, 58, 48, 57, 65, 70, 97, 102, 
	48, 57, 46, 48, 57, 48, 57, 46, 
	48, 57, 48, 57, 32, 48, 57, 32, 
	48, 57, 32, 46, 48, 57, 46, 46, 
	48, 57, 46, 46, 58, 48, 57, 65, 
	70, 97, 102, 46, 58, 48, 57, 65, 
	70, 97, 102, 58, 70, 102, 48, 57, 
	65, 69, 97, 101, 58, 70, 102, 48, 
	57, 65, 69, 97, 101, 58, 70, 102, 
	48, 57, 65, 69, 97, 101, 32, 33, 
	45, 48, 57, 65, 125, 0
]

class << self
	attr_accessor :_irc_message_parser_single_lengths
	private :_irc_message_parser_single_lengths, :_irc_message_parser_single_lengths=
end
self._irc_message_parser_single_lengths = [
	0, 1, 2, 1, 5, 4, 5, 4, 
	5, 4, 5, 4, 5, 4, 5, 4, 
	5, 4, 5, 4, 5, 4, 5, 4, 
	5, 4, 5, 4, 5, 4, 5, 4, 
	3, 3, 3, 0, 3, 1, 2, 0, 
	4, 5, 5, 1, 4, 3, 0, 4, 
	0, 1, 0, 1, 0, 1, 0, 1, 
	0, 1, 0, 1, 0, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 3, 1, 
	0, 2, 0, 1, 0, 1, 0, 1, 
	1, 1, 1, 1, 1, 1, 2, 2, 
	3, 3, 3, 3, 0
]

class << self
	attr_accessor :_irc_message_parser_range_lengths
	private :_irc_message_parser_range_lengths, :_irc_message_parser_range_lengths=
end
self._irc_message_parser_range_lengths = [
	0, 3, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 5, 3, 3, 2, 3, 
	5, 0, 0, 5, 5, 3, 3, 5, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 1, 1, 1, 1, 1, 1, 
	1, 0, 1, 0, 1, 0, 3, 3, 
	3, 3, 3, 2, 0
]

class << self
	attr_accessor :_irc_message_parser_index_offsets
	private :_irc_message_parser_index_offsets, :_irc_message_parser_index_offsets=
end
self._irc_message_parser_index_offsets = [
	0, 0, 5, 9, 11, 17, 22, 28, 
	33, 39, 44, 50, 55, 61, 66, 72, 
	77, 83, 88, 94, 99, 105, 110, 116, 
	121, 127, 132, 138, 143, 149, 154, 160, 
	165, 169, 173, 177, 183, 190, 195, 200, 
	204, 214, 220, 226, 233, 243, 250, 254, 
	264, 268, 273, 277, 282, 286, 291, 295, 
	300, 304, 309, 313, 318, 322, 327, 332, 
	337, 342, 347, 352, 357, 362, 367, 374, 
	379, 383, 389, 391, 394, 396, 399, 401, 
	404, 407, 409, 412, 414, 417, 419, 425, 
	431, 438, 445, 452, 458
]

class << self
	attr_accessor :_irc_message_parser_trans_targs
	private :_irc_message_parser_trans_targs, :_irc_message_parser_trans_targs=
end
self._irc_message_parser_trans_targs = [
	35, 2, 38, 38, 0, 3, 4, 2, 
	0, 92, 0, 0, 0, 3, 4, 33, 
	5, 0, 0, 3, 6, 5, 0, 0, 
	3, 6, 33, 7, 0, 0, 3, 8, 
	7, 0, 0, 3, 8, 33, 9, 0, 
	0, 3, 10, 9, 0, 0, 3, 10, 
	33, 11, 0, 0, 3, 12, 11, 0, 
	0, 3, 12, 33, 13, 0, 0, 3, 
	14, 13, 0, 0, 3, 14, 33, 15, 
	0, 0, 3, 16, 15, 0, 0, 3, 
	16, 33, 17, 0, 0, 3, 18, 17, 
	0, 0, 3, 18, 33, 19, 0, 0, 
	3, 20, 19, 0, 0, 3, 20, 33, 
	21, 0, 0, 3, 22, 21, 0, 0, 
	3, 22, 33, 23, 0, 0, 3, 24, 
	23, 0, 0, 3, 24, 33, 25, 0, 
	0, 3, 26, 25, 0, 0, 3, 26, 
	33, 27, 0, 0, 3, 28, 27, 0, 
	0, 3, 28, 33, 29, 0, 0, 3, 
	30, 29, 0, 0, 3, 30, 33, 31, 
	0, 0, 3, 32, 31, 3, 32, 33, 
	0, 0, 0, 3, 34, 0, 0, 3, 
	34, 36, 40, 91, 40, 91, 0, 37, 
	36, 39, 36, 36, 36, 0, 37, 2, 
	38, 38, 0, 3, 4, 38, 38, 0, 
	36, 36, 36, 0, 37, 41, 40, 39, 
	40, 40, 91, 40, 91, 0, 0, 0, 
	0, 0, 0, 42, 0, 0, 0, 37, 
	43, 42, 44, 47, 47, 45, 47, 45, 
	0, 37, 45, 46, 62, 47, 47, 45, 
	47, 45, 0, 37, 45, 46, 45, 45, 
	45, 0, 45, 45, 45, 0, 37, 45, 
	46, 48, 47, 47, 45, 47, 45, 0, 
	49, 49, 49, 0, 50, 49, 49, 49, 
	0, 51, 51, 51, 0, 52, 51, 51, 
	51, 0, 53, 53, 53, 0, 54, 53, 
	53, 53, 0, 55, 55, 55, 0, 56, 
	55, 55, 55, 0, 57, 57, 57, 0, 
	58, 57, 57, 57, 0, 59, 59, 59, 
	0, 60, 59, 59, 59, 0, 61, 61, 
	61, 0, 37, 61, 61, 61, 0, 63, 
	49, 49, 49, 0, 64, 49, 49, 49, 
	0, 65, 51, 51, 51, 0, 66, 51, 
	51, 51, 0, 67, 53, 53, 53, 0, 
	68, 53, 53, 53, 0, 69, 55, 55, 
	55, 0, 70, 55, 55, 55, 0, 71, 
	88, 88, 57, 57, 57, 0, 72, 57, 
	57, 57, 0, 73, 59, 59, 0, 74, 
	60, 86, 59, 59, 0, 75, 0, 76, 
	84, 0, 77, 0, 78, 82, 0, 79, 
	0, 37, 80, 0, 37, 81, 0, 37, 
	0, 78, 83, 0, 78, 0, 76, 85, 
	0, 76, 0, 74, 60, 87, 59, 59, 
	0, 74, 60, 59, 59, 59, 0, 58, 
	89, 89, 57, 57, 57, 0, 58, 90, 
	90, 57, 57, 57, 0, 58, 71, 71, 
	57, 57, 57, 0, 37, 41, 91, 91, 
	91, 0, 0, 0
]

class << self
	attr_accessor :_irc_message_parser_trans_actions
	private :_irc_message_parser_trans_actions, :_irc_message_parser_trans_actions=
end
self._irc_message_parser_trans_actions = [
	1, 44, 44, 44, 21, 0, 0, 15, 
	21, 0, 21, 21, 21, 0, 0, 0, 
	32, 21, 21, 11, 11, 9, 21, 21, 
	0, 0, 0, 32, 21, 21, 11, 11, 
	9, 21, 21, 0, 0, 0, 32, 21, 
	21, 11, 11, 9, 21, 21, 0, 0, 
	0, 32, 21, 21, 11, 11, 9, 21, 
	21, 0, 0, 0, 32, 21, 21, 11, 
	11, 9, 21, 21, 0, 0, 0, 32, 
	21, 21, 11, 11, 9, 21, 21, 0, 
	0, 0, 32, 21, 21, 11, 11, 9, 
	21, 21, 0, 0, 0, 32, 21, 21, 
	11, 11, 9, 21, 21, 0, 0, 0, 
	32, 21, 21, 11, 11, 9, 21, 21, 
	0, 0, 0, 32, 21, 21, 11, 11, 
	9, 21, 21, 0, 0, 0, 32, 21, 
	21, 11, 11, 9, 21, 21, 0, 0, 
	0, 32, 21, 21, 11, 11, 9, 21, 
	21, 0, 0, 0, 32, 21, 21, 11, 
	11, 9, 21, 21, 0, 0, 0, 32, 
	21, 21, 11, 11, 9, 0, 0, 0, 
	21, 21, 21, 3, 29, 21, 21, 0, 
	13, 26, 48, 35, 48, 35, 21, 19, 
	7, 7, 7, 7, 7, 21, 0, 23, 
	23, 23, 21, 0, 0, 15, 15, 21, 
	7, 7, 7, 21, 41, 5, 38, 7, 
	38, 38, 5, 38, 5, 21, 21, 21, 
	21, 21, 21, 5, 21, 21, 21, 17, 
	5, 5, 5, 5, 5, 5, 5, 5, 
	21, 17, 5, 5, 5, 5, 5, 5, 
	5, 5, 21, 17, 5, 5, 5, 5, 
	5, 21, 5, 5, 5, 21, 17, 5, 
	5, 5, 5, 5, 5, 5, 5, 21, 
	5, 5, 5, 21, 5, 5, 5, 5, 
	21, 5, 5, 5, 21, 5, 5, 5, 
	5, 21, 5, 5, 5, 21, 5, 5, 
	5, 5, 21, 5, 5, 5, 21, 5, 
	5, 5, 5, 21, 5, 5, 5, 21, 
	5, 5, 5, 5, 21, 5, 5, 5, 
	21, 5, 5, 5, 5, 21, 5, 5, 
	5, 21, 17, 5, 5, 5, 21, 5, 
	5, 5, 5, 21, 5, 5, 5, 5, 
	21, 5, 5, 5, 5, 21, 5, 5, 
	5, 5, 21, 5, 5, 5, 5, 21, 
	5, 5, 5, 5, 21, 5, 5, 5, 
	5, 21, 5, 5, 5, 5, 21, 5, 
	5, 5, 5, 5, 5, 21, 5, 5, 
	5, 5, 21, 5, 5, 5, 21, 5, 
	5, 5, 5, 5, 21, 5, 21, 5, 
	5, 21, 5, 21, 5, 5, 21, 5, 
	21, 17, 5, 21, 17, 5, 21, 17, 
	21, 5, 5, 21, 5, 21, 5, 5, 
	21, 5, 21, 5, 5, 5, 5, 5, 
	21, 5, 5, 5, 5, 5, 21, 5, 
	5, 5, 5, 5, 5, 21, 5, 5, 
	5, 5, 5, 5, 21, 5, 5, 5, 
	5, 5, 5, 21, 17, 5, 5, 5, 
	5, 21, 21, 0
]

class << self
	attr_accessor :_irc_message_parser_eof_actions
	private :_irc_message_parser_eof_actions, :_irc_message_parser_eof_actions=
end
self._irc_message_parser_eof_actions = [
	0, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 21, 21, 21, 21, 
	21, 21, 21, 21, 0
]

class << self
	attr_accessor :irc_message_parser_start
end
self.irc_message_parser_start = 1;
class << self
	attr_accessor :irc_message_parser_first_final
end
self.irc_message_parser_first_final = 92;
class << self
	attr_accessor :irc_message_parser_error
end
self.irc_message_parser_error = 0;

class << self
	attr_accessor :irc_message_parser_en_main
end
self.irc_message_parser_en_main = 1;


# line 64 "lib/ircbgb/message_parser.rl"

    def self.parse str
      data = str
      server = ''
      user_mask = ''
      para = ''
      rest = ''
      params = []
      source = nil
      cmd = ''

      
# line 357 "lib/ircbgb/message_parser.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = irc_message_parser_start
end

# line 76 "lib/ircbgb/message_parser.rl"
      
# line 366 "lib/ircbgb/message_parser.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _irc_message_parser_key_offsets[cs]
	_trans = _irc_message_parser_index_offsets[cs]
	_klen = _irc_message_parser_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _irc_message_parser_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _irc_message_parser_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _irc_message_parser_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _irc_message_parser_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _irc_message_parser_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _irc_message_parser_trans_targs[_trans]
	if _irc_message_parser_trans_actions[_trans] != 0
		_acts = _irc_message_parser_trans_actions[_trans]
		_nacts = _irc_message_parser_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _irc_message_parser_actions[_acts - 1]
when 0 then
# line 5 "lib/ircbgb/message_parser.rl"
		begin
 eof = pe 		end
when 1 then
# line 6 "lib/ircbgb/message_parser.rl"
		begin
 cmd = '' 		end
when 2 then
# line 7 "lib/ircbgb/message_parser.rl"
		begin
 server = '' 		end
when 3 then
# line 8 "lib/ircbgb/message_parser.rl"
		begin
 rest = '' 		end
when 4 then
# line 9 "lib/ircbgb/message_parser.rl"
		begin
 param = '' 		end
when 5 then
# line 10 "lib/ircbgb/message_parser.rl"
		begin
 user_mask = '' 		end
when 6 then
# line 11 "lib/ircbgb/message_parser.rl"
		begin
 user_mask << data[p] 		end
when 7 then
# line 12 "lib/ircbgb/message_parser.rl"
		begin
 server << data[p] 		end
when 8 then
# line 13 "lib/ircbgb/message_parser.rl"
		begin
 param << data[p] 		end
when 9 then
# line 14 "lib/ircbgb/message_parser.rl"
		begin
 params << param 		end
when 10 then
# line 15 "lib/ircbgb/message_parser.rl"
		begin
 rest << data[p] 		end
when 11 then
# line 16 "lib/ircbgb/message_parser.rl"
		begin
 cmd << data[p] 		end
when 12 then
# line 17 "lib/ircbgb/message_parser.rl"
		begin

    source = ::Ircbgb::User.parse(user_mask)
  		end
when 13 then
# line 20 "lib/ircbgb/message_parser.rl"
		begin

    source = ::Ircbgb::Server.new(server)
  		end
when 14 then
# line 26 "lib/ircbgb/message_parser.rl"
		begin

    raise ::Ircbgb::MessageFormatError, "invalid form #{data.inspect} at #{p} '#{data[p]}'"
  		end
# line 512 "lib/ircbgb/message_parser.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	__acts = _irc_message_parser_eof_actions[cs]
	__nacts =  _irc_message_parser_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _irc_message_parser_actions[__acts - 1]
when 14 then
# line 26 "lib/ircbgb/message_parser.rl"
		begin

    raise ::Ircbgb::MessageFormatError, "invalid form #{data.inspect} at #{p} '#{data[p]}'"
  		end
# line 546 "lib/ircbgb/message_parser.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 77 "lib/ircbgb/message_parser.rl"

      params << rest unless rest.empty?

      ::Ircbgb::Message.new source, cmd, params
    end
  end
end

