#!/bin/env python
# -*- coding: utf8 -*-
import threading
import persistence
import parsexml
import json
import copy
import time
import globalv
import os

class SaveWorker(threading.Thread):
    def __init__(self, config, LS, **kwargs):
        self.config = config
        self.LS = LS
        for x in self.LS: print x
        threading.Thread.__init__(self,kwargs=kwargs)

    def resetDS(self):
        #outdate deal
        outdid = []
        for x in self.LS["deal"]:
            try:
                if int(self.LS["deal"][x]["deal"]["end_time"])<tt: outdid.append(x)
            except: outdid.append(x)
        for x in outdid: del self.LS["deal"][x]

        #offline deal
        yesdealids = []; notdealids = [];
        if fetchsuccess:
            alldealids = [x for x in self.LS["deal"]]
            for x in self.LS["citydealid"].values(): yesdealids = yesdealids+x
            notdealids = [x for x in alldealids if x not in yesdealids]
            for x in notdealids: del self.LS["deal"][x]

        #copy to DS
        globalv.DS = copy.deepcopy(self.LS)


    def run(self):
        #reset globalv.DS
        self.resetDS()

        #save pickle
        DataWorker.log(self.config["spider.log"], "DEAL: try save pickle data");
        persistence.persistence_save(self.LS, self.config["data.pickle"])
        DataWorker.log(self.config["spider.log"], "DEAL: save pickle data done");

        #convert to json
        DataWorker.log(self.config["spider.log"], "DEAL: try save json data");
        result = {}
        for city in self.LS["city"]:
            dealids = self.LS["citydealid"].get(city)
            try: result[city] = [self.LS["deal"].get(x) for x in dealids if x in self.LS["deal"]]
            except: None
        dumpdata = json.dumps(result)
        file(self.config["temp.json"],"w+").write(dumpdata);
        os.rename(self.config["temp.json"], self.config["data.json"]);
        DataWorker.log(self.config["spider.log"], "DEAL: save json data done");

class DataWorker(threading.Thread):
    def __init__(self, config, **kwargs):
        self.config = config
        self.rlock = threading.RLock()
        self.wlock = threading.Lock()
        self.LS = {"city":{}, "deal": {}, "citydealid":{}, "dealing":{}}
        threading.Thread.__init__(self,kwargs=kwargs)

    def loadFromStore(self):
        self.wlock.acquire()
        no = persistence.persistence_load(self.config["data.pickle"])
        if no.get("citydealid"): self.LS = no
        globalv.DS = copy.deepcopy(self.LS)
        self.wlock.release()

    def resetCity(self, city, deals):
        self.wlock.acquire()
        if deals: 
            dealids = [d["deal"]["deal_id"] for d in deals]
            self.LS["citydealid"][city] = dealids
            for v in deals: 
                self.LS["deal"][v["deal"]["deal_id"]] = v;
                v["citynum"] = len([1 for x in self.LS["citydealid"].values() if v["deal"]["deal_id"] in x]);
        self.wlock.release()

    def saveToStore(self):
        worker = SaveWorker(self.config, self.LS)
        worker.start()

    def run(self):
        while True:
            try:
                #fetch city
                fetchsuccess = True
                tt = int(time.time())
                citylist = parsexml.parse_division()
                if citylist==None: 
                    DataWorker.log(self.config["spider.log"], "SUCC[CITY]: citylist fetch error");
                    time.sleep(3); 
                    continue;
                citylist["daxinganling"] = {"id":"daxinganling", "name":"大兴安岭"}
                if citylist: self.LS["city"] = citylist
                citylist["daxinganling"] = {"id":"daxinganling"}
                cityids = self.LS["city"].keys()
                
                #fetch citydeals
                for cv in cityids:
                    dealr = parsexml.parse_deal(cv)
                    if dealr: 
                        DataWorker.log(self.config["spider.log"], "SUCC[DEAL]: fetch %s success" % (cv));
                        self.resetCity(cv, dealr["response"]["deals"]["data"]);
                    else: 
                        DataWorker.log(self.config["spider.log"], "SUCC[DEAL]: fetch %s fail" % (cv));
                        fetchsuccess = False
                    time.sleep(0.1);

                #save to store
                self.saveToStore()
                time.sleep(self.config["spider.interval"]);
            except Exception, e: 
                DataWorker.log(self.config["spider.log"], e);

    @staticmethod 
    def log(f, s):
        ts = "%s-%s-%s %s:%s:%s" % time.localtime()[0:6] 
        file(f,"a+").writelines("%s\t%s\n" %(ts,s));
