##ladder
##{"Ladder": "game",
##"Game": 0,
##"Contestants": int, 
##"Events": [ ],
##"Players": [ ]
##}
##
##
##"Players": {"ID": x, "elo": x}
##"Event": {"Date": x, "Entrants": x, "Matches": [ ] }
##"Matches": { "Team1": x, "Team2": x, "Score1": , "Score2": , "Stages": }
##
##Contestants
##{"Name": , x, "Attendance": x, "Ladders": [ ]} 
##
##Ladder: {"LadderID": , "Played": , "Scores": [ ]}
##
##Score: {"EnemyID": , "W":, "L": }
#Queue {'Event': ladder, 'setups': 0, 'InProg': [], 'Queue': []}
#InProg {'team1': uid, 'team2': uid}
#Queue: [ladderuid]

import json
import datetime

path = "C:/Users/admin/Documents/smash/"
LADDERS = []
PLAYERS = []
QUEUES = []
EVENT = 0

def addLadder(name, gameid):
    ladder = {'Ladder': '', 'Game': 0, 'Size': 0, 'Events': [], 'Players':[]}
    ladder['Ladder'] = name
    ladder['Game'] = gameid
    LADDERS.append(ladder)


def addPlayer(args):
    player = {'Name': args[0], 'last': -1, 'Ladders': []}
    uid = len(PLAYERS)
    PLAYERS.append(player)
    if(len(args) >= 2):
        for x in range (0, (len(args)/2)):
            addPlayerFull(uid, args[x+1], args[x+2])
    else:
        for x in range (0, len(LADDERS)):
            addPlayerFull(uid, x, 1200)
        
        
def addPlayerFull(uid, lad, elo):
    pl = {'UID': uid, 'elo': elo}
    sc = {'LID': lad, 'played': 0, 'Scores': [ ]}
    LADDERS[lad]['Players'].append(pl)
    LADDERS[lad]['Size'] += 1
    PLAYERS[uid]['Ladders'].append(sc)
    

def printLadders():
    for x in range(0, len(LADDERS)):
        print(x, " -", LADDERS[x]['Ladder'], "( E: ", LADDERS[x]['Size'], ")")

def load():
    f = open(path + 'ladder.jsn')
    LADDERS.extend(json.load(f))
    f.close()
    f = open(path + 'player.jsn')
    PLAYERS.extend(json.load(f))
    f.close()

def save():
    f = open(path + 'ladder.jsn', mode='w+')
    json.dump(LADDERS, f, indent=2)
    f.close()
    f = open(path + 'player.jsn', mode='w+')
    json.dump(PLAYERS, f, indent=2)
    f.close()

##Queue {'Event': ladder, 'setups': 0, 'InProg': [], 'Queue': []}
##InProg {'team1': uid, 'team2': uid}
##Queue: [ladderuid]
##"Event": {"Date": x, "Entrants": x, "Matches": [ ] }

def addEvent(lid, setups):
    queue = {'Event': lid, 'setups': setups, 'InProg': [], 'Queue': []}
    QUEUES.append(queue)
    #event = {'Date': datetime.date.today().isoformat(), 'entrants': 0, 'Matches': []}
    #LADDERS[lid]['Events'].append(event)

def getName(qid, lid):
    lad = QUEUES[qid]['Event']
    pid = LADDERS[lad]['Players'][lid]['UID']
    return PLAYERS[pid]['Name']
    
def printQueue(qid):
    lad = QUEUES[qid]['Event']
    print("Queue for:", LADDERS[lad]['Ladder'])
    if(len(QUEUES[qid]['InProg']) > 0):
        for x in range(0, len(QUEUES[qid]['InProg'])):
            pl1 = QUEUES[qid]['InProg'][x]['team1']
            pl2 = QUEUES[qid]['InProg'][x]['team2']
            print("In progress:", getName(qid, pl1), "vs", getName(qid, pl2))
