## categories:
#STRAIGHT_FLUSH = 9
#KIND4          = 8
#FULL_HOUSE     = 7
#FLUSH          = 6
#STRAIGHT       = 5
#KIND3          = 4
#TWO_PAIR       = 3
#PAIR           = 2
#HIGH           = 1
#
#pow_base = 100
#pows = (Math.pow(pow_base,i) for i in [0...5])
#
## returns < 0 if hand a < hand b
## returns 0 if hand a ties hand b
## returns > 0 if hand a > hand b
#compare_poker_hand = (handA, handB) ->
#    classA = classify_hand(handA)
#    classB = classify_hand(handB)
#    if classA[0] != classB[0]
#        return classA[0] - classB[0]
#    else
#        return classA[1] - classB[1]
#
#poker_hand_comparator = (handA, handB) ->
#  diff = compare_poker_hand(handA, handB)
#  if diff > 0
#    return 1
#  else if diff == 0
#    return 0
#  else
#    return -1
#
## set of numbers
#get_straight = (ranks) ->
#  rank_order = [1..14]
#  rank_order[0] = 14
#
#  streak = 0
#  for i in [13...-1]
#    if rank_order[i] of ranks
#      streak += 1
#      if streak == 5
#        return rank_order[i + 4]
#    else
#      streak = 0
#  return 0
#
## returns tiebreaker number for a set of 5 cards (taking the 5 highest)
#get_tiebreak = (ranks, num) ->
#  if not num?
#    num = 5
#  ranks = (rank for rank of ranks)
#  ranks.sort()
#  tiebreak = 0
#  for i in [-1...-num-1]
#    tiebreak *= pow_base
#    tiebreak += ranks[i]
#  return tiebreak
#
#
#SUITS = ['c', 'd', 'h', 's']
## return (category, strength)
## strength denotes the value for tiebreaking same category
#
#classify_hand = (hand) ->
#  if hand.length < 5
#    throw new Error 'hand of wrong size'
#
#  #####################
#  # ORGANIZE BY SUITS
#  #####################
#
#  suits = (card[1] for card in hand)
#  # put into buckets
#  suit_hands = {}
#  for x in SUITS
#    suit_hands[x] = {}
#  for card in hand
#    suit_hands[card[1]][card[0]] = true
#
#  #####################
#  # ORGANIZE BY RANKS
#  #####################
#
#  ranks = (card[0] for card in hand)
#  ranks.sort()
#  # put into buckets
#
#  rank_counts = (0 for i in [0...15])
#  for x in ranks
#    rank_counts[x] += 1
#  rank_count_sets = {}
#  for x in [1..4]
#    rank_count_sets[x] = {}
#  for i in [2..14]
#    count = rank_counts[i]
#    if count of rank_count_sets
#      rank_count_sets[count][i] = true
#    else
#      assert count==0, 'count was non-zero #{count}'
#
#  # CHECK FOR A STRAIGHT FLUSH
#  console.log hand
#  console.log suit_hands
#
#  max_straight_flush = 0
#  for suit of suit_hands
#    straight_num = get_straight(suit_hands[suit])
#    if straight_num > max_straight_flush
#      max_straight_flush = straight_num
#    console.log 'suit', suit, suit_hands[suit], max_straight_flush
#  if max_straight_flush > 0
#    # tiebreak by high card
#    return [STRAIGHT_FLUSH, max_straight_flush]
#
#  # CHECK FOR FOUR OF A KIND
#
#  if rank_count_sets[4].length > 0
#    return [KIND4, Math.max.apply(null, rank_count_sets[4])]
#
#  # CHECK FOR FULL HOUSE
#
#  if (rank_count_sets[3].length >= 2) or (rank_count_sets[3].length == 1 and rank_count_sets[2].length >= 1)
#    trips = Math.max.apply(null, rank_count_sets[3])
#    return [FULL_HOUSE, trips]
#
#  # CHECK FOR FLUSH
#
#  max_tiebreak = 0
#  for suit in suit_hands
#    if suit_hands[suit].length >= 5
#      num = get_tiebreak(suit_hands[suit])
#      if num > max_tiebreak
#        max_tiebreak = num
#  if max_tiebreak > 0
#    return [FLUSH, max_tiebreak]
#
#  # CHECK FOR STRAIGHT
#
#  high_rank = get_straight(ranks)
#  if high_rank > 0
#    return [STRAIGHT, high_rank]
#
#  # CHECK FOR THREE OF A KIND
#
#  if rank_count_sets[3].length >= 1
#    assert rank_count_sets[2].length == 0 and rank_count_sets[3].length == 1 and rank_count_sets[4].length == 0
#    return [KIND3, get_tiebreak(rank_count_sets[1], 2)]
#
#  # CHECK FOR TWO-PAIR
#
#  if rank_count_sets[2].length >= 2
#    assert rank_count_sets[3].length == 0 and rank_count_sets[4].length == 0
#    sorted_pairs = sorted(list(rank_count_sets[2]))
#    remaining_candidates = {}
#
#    for x in sorted_pairs.slice(0,-2)
#      remaining_candidates[x] = true
#    for x in rank_count_sets[1]
#      remaining_candidates[x] = true
#
#    tiebreak = sorted_pairs[sorted_pairs.length-1] * pows[2] + sorted_pairs[sorted_pairs.length-2] * pows[1] + Math.max.apply(null, remaining_candidates)
#    return [TWO_PAIR, tiebreak]
#
#  # CHECK FOR PAIR
#
#  if rank_count_sets[2].length >= 1
#    assert rank_count_sets[2].length == 1 and rank_count_sets[3].length == 0 and rank_count_sets[4].length == 0
#    pair = Math.max.apply(null, rank_count_sets[2])
#    tiebreak = pair * pows[3] + get_tiebreak(rank_count_sets[1], 3)
#    return [PAIR, tiebreak]
#
#  # CHECK FOR HIGH
#  assert rank_count_sets[2].length == 0 and rank_count_sets[3].length == 0 and rank_count_sets[4].length == 0
#  tiebreak = get_tiebreak(rank_count_sets[1])
#  return [HIGH, tiebreak]
#
#string_to_number_mapping = {
#  '1' : 14
#  '2' : 2
#  '3' : 3
#  '4' : 4
#  '5' : 5
#  '6' : 6
#  '7' : 7
#  '8' : 8
#  '9' : 9
#  '10': 10
#  '11': 11
#  '12': 12
#  '13': 13
#  '14': 14
#  'j' : 11
#  'J' : 11
#  'q' : 12
#  'Q' : 12
#  'k' : 13
#  'K' : 13
#  'a' : 14
#  'A' : 14
#}
#
#number_to_string_mapping = {
#  1  :  'A',
#  2  :  '2',
#  3  :  '3',
#  4  :  '4',
#  5  :  '5',
#  6  :  '6',
#  7  :  '7',
#  8  :  '8',
#  9  :  '9',
#  10 : '10',
#  11 :  'J',
#  12 :  'Q',
#  13 :  'K',
#  14 :  'A',
#}
#
#string_to_card = (string) ->
#  num = string.slice(0,-1)
#  suit = string[string.length-1]
#  if isNaN(parseInt(num))
#    num = string_to_number_mapping[num]
#  else
#    num = parseInt(num)
#  return [num, suit]
#
#card_to_string = (card) ->
#  return number_to_string_mapping[card[0]] + card[1]
#
#
#
#compare_hands = (handA, handB)->
#  handA = (string_to_card(x) for x in handA)
#  handB = (string_to_card(x) for x in handB)
#  return poker_hand_comparator(handA, handB)
#
#assert_correct = (hand_1, hand_2, value) ->
#  actual_value = compare_hands(hand_1, hand_2)
#  if actual_value != value
#    console.log 'Test failed!'
#    console.log '  Hand 1: ', hand_1
#    console.log '    classification: ', classify_hand((string_to_card(x) for x in hand_1))
#    console.log '  Hand 2: ', hand_2
#    console.log '    classification: ', classify_hand((string_to_card(x) for x in hand_2))
#    console.log '  Should have been: ' , value
#    console.log '  Instead was     : ' , actual_value
#
#
#test_hands_list = (hands_list) ->
#  for i in [0...hands_list.length]
#    for j in [i+1...hands_list.length]
#      console.log 'testing hands_list', hands_list[i]
#      console.log 'testing hands_list', hands_list[j]
#      assert_correct(hands_list[i], hands_list[j], 1)
#      assert_correct(hands_list[j], hands_list[i], -1)
#
#hands_list = [
#  ['10c',  'Jc',  'Qc',  'Kc',  'Ac'], # straight flush
#  [ '2c',  '3c',  '4c',  '5c',  '6c'], # straight flush
#  [ 'Ac',  '2c',  '3c',  '4c',  '5c'], # straight flush
#  [ '2c',  '2d',  '2h',  '2s',  '6c'], # 4 of a kind
#  [ '2c',  '2d',  '2h',  '6s',  '6c'], # full house
#  [ '2c',  '3c',  '4c',  '5c',  '7c'], # flush
#  ['10c',  'Jc',  'Qc',  'Kc',  'Ad'], # straight
#  [ '2c',  '3c',  '4c',  '5c',  '6d'], # straight
#  [ 'Ac',  '2c',  '3c',  '4c',  '5d'], # straight
#  [ '2c',  '2d',  '2h',  '5s',  '6c'], # 3 of a kind
#  [ '2c',  '2d',  '4h',  '6s',  '6c'], # 2 pair
#  [ '2c',  '2d',  '3c',  '4c',  '6c'], # pair
#  [ '2c',  '3c',  '4c',  '5c',  '7d'], # high
#]
#
#test_hands_list(hands_list)
#
#hands_list = [
#  ['2c', '2s', '5c', '6c', '6s'],
#  ['2c', '2s', '4c', '6c', '6s'],
#  ['2c', '2s', '3c', '6c', '6s'],
#]
#
#test_hands_list(hands_list)
#
## testing straights
#hands_list = [
#  ['10c',  'Jd',  'Qh',  'Ks' ,  'Ac'],
#  [ '9c', '10d',  'Jh',  'Qs' ,  'Kc'],
#  [ '8c',  '9d', '10h',  'Js' ,  'Qc'],
#  [ '7c',  '8d',  '9h', '10s' ,  'Jc'],
#  [ '6c',  '7d',  '8h',  '9s' , '10c'],
#  [ '5c',  '6d',  '7h',  '8s' ,  '9c'],
#  [ '4c',  '5d',  '6h',  '7s' ,  '8c'],
#  [ '3c',  '4d',  '5h',  '6s' ,  '7c'],
#  [ '2c',  '3d',  '4h',  '5s' ,  '6c'],
#  [ 'Ac',  '2d',  '3h',  '4s' ,  '5c'],
#]
#
#test_hands_list(hands_list)
#
## two-pair
#hands_list = [
#  ['4c', '4s', '5c', '6c', '6s'],
#  ['3c', '3s', '5c', '6c', '6s'],
#  ['2c', '2s', '5c', '6c', '6s'],
#  ['3c', '3s', '5c', '4c', '4s'],
#  ['2c', '2s', '5c', '4c', '4s'],
#  ['2c', '2s', '5c', '3c', '3s'],
#  ['2c', '4s', '5c', '6c', '6s'],
#  ['2c', '3s', '5c', '6c', '6s'],
#]
#
#test_hands_list(hands_list)
#
## pairs
#hands_list = [
#  ['2c', '3s', '4c', 'Ac', 'As'],
#  ['2c', '4s', '5c', '6c', '6s'],
#  ['2c', '3s', '5c', '6c', '6s'],
#  ['2c', '3s', '4c', '6c', '6s'],
#  ['Ac', '3s', '4c', '5c', '5s'],
#  ['2c', '3s', '4c', '5c', '5s'],
#]
#
#test_hands_list(hands_list)
#
## high card
#hands_list = [
#  [ '7c',  '9s',  'Jc',  'Kc',  'As'],
#  [ '5c',  '7s',  '9c',  'Jc',  'Ks'],
#  [ '3c',  '7s',  '9c',  'Jc',  'Ks'],
#  [ '2c',  '3s',  '9c',  'Jc',  'Ks'],
#  [ '2c',  '7s',  '8c',  'Jc',  'Ks'],
#  [ '2c',  '7s',  '9c', '10c',  'Ks'],
#  [ '2c',  '3s',  '4c',  '9c',  'Js'],
#  [ '5c',  '6s',  '7c',  '8c',  'Js'],
#]
#
#test_hands_list(hands_list)
#
#handA = ['2c', '3c', '4c', '5c', '6c']
#handB = ['2d', '3d', '4d', '5d', '6d']
#assert_correct(handA, handB, 0)
#
#handA = ['2c', '2d', '4c', '3c', '3d']
#handB = ['2h', '2s', '4h', '3h', '3s']
#assert_correct(handA, handB, 0)
#
#handA = ['2c', '2d', '4c', '3c', '3d']
#handB = ['2h', '2s', '4h', '3h', '3s']
#assert_correct(handA, handB, 0)
#
#handA = ['2c', '4d', '8c', 'Qc', 'Ad']
#handB = ['2h', '4s', '8h', 'Qh', 'As']
#assert_correct(handA, handB, 0)
#
#
