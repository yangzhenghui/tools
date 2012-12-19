#!/bin/bash                                                                                                                   
cd /opt/log/seo/                                                                                                              
find . -type f -mtime +7  -print >> /opt/log/seo/del.log                                                                      
find . -type f -mtime +7  | xargs rm -rf
