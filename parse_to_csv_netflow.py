import csv
import os
import sys
from time import mktime
from time import strptime
from collections import OrderedDict
import operator
'''
input_dir = sys.argv[1]
output_dir = sys.argv[2]
output_name = sys.argv[3]
'''

input_dir = 'input'
output_dir = 'output'
output_name = '1'

data_dir='hadoop_data'

NETFLOW_KEYS = ['network.flow.bytes']

TIME_HEADERS = ['time_in_secs']
NETFLOW_HEADERS = NETFLOW_KEYS

def tstamp_to_secs(timestamp):
    localtime = timestamp[0:19]
    timezone = timestamp[19:]
    if timezone == 'Z':
        timezone = 'UTC'
    if len(timezone) == 3:
        time_in_seconds = mktime(strptime(localtime + timezone, '%Y-%m-%dT%H:%M:%S%Z'))
    else:
        tail_number = timezone[1:]
        localtime = localtime[:-2] + str(int(localtime[-2:-1]) + int(tail_number[0])/5)
        time_in_seconds = mktime(strptime(localtime, '%Y-%m-%d %H:%M:%S'))
    return time_in_seconds


all_file_names = os.listdir(input_dir)

# get a list of all instance names in netflow data
netflow_instances = set([])
for filename in all_file_names:
    filepath = os.path.join(input_dir, filename)
    if not os.path.isfile(filepath):
        continue
    with open(filepath) as f:
        while True:
            line = f.readline().rstrip('\n')
            if not line:
                break
            record = eval(line)
            if record['name'] in NETFLOW_KEYS:
                instance_id = record['resource_metadata']['instance_id']
                netflow_instances.add(instance_id)
import pdb
feature_idx_dict = {}
all_headers = TIME_HEADERS + NETFLOW_HEADERS
for idx in range(len(all_headers)):
    feature_idx_dict[all_headers[idx]] = idx

feature_dict = {}
feature_dim = len(all_headers)

for filename in all_file_names:
    filepath = os.path.join(input_dir, filename)
    if not os.path.isfile(filepath):
        continue
    with open(filepath) as f:
        while True:
            line = f.readline().rstrip('\n')
            if not line:
                break
            record = eval(line)
            if record['name'] in NETFLOW_KEYS:
                src_instance_id = record['resource_metadata']['instance_id']
            else:
                continue
            time_stamp = record['timestamp']
            seconds = tstamp_to_secs(time_stamp)
            netflow_dict = record['resource_metadata']['parameters']
            feature_idx = feature_idx_dict.get(record['name'], None)
            for nf in netflow_dict.keys():
                if not nf == 'OUTSIDE':
                #if nf in netflow_instances:
                    dst_instance_id = nf
                    feature_key = (src_instance_id, dst_instance_id, time_stamp)
                    feature_dict.setdefault(feature_key, [0 for d in range(feature_dim)])
                    feature_dict[feature_key][feature_idx] = netflow_dict[nf]
                    feature_dict[feature_key][feature_idx_dict[TIME_HEADERS[0]]] = seconds
    f.close()

sorted_feature_dict = OrderedDict(sorted(feature_dict.iteritems(), key = operator.itemgetter(1)))

output_filepath = os.path.join(output_dir, output_name)
with open(output_filepath, 'wb') as f:
    writer = csv.writer(f)
    #header = ['src_instance_id', 'dst_instance_id'] + TIME_HEADERS + NETFLOW_HEADERS

    #header = ['src_dst_instance_id'] + TIME_HEADERS + NETFLOW_HEADERS
    header = ['src_id'] + ['dst_id'] + TIME_HEADERS + NETFLOW_HEADERS
    writer.writerow(header)
    for feature_key in sorted_feature_dict.keys():
        (src_instance_id, dst_instance_id, time_stamp) = feature_key
        feature_vect = sorted_feature_dict[feature_key]
        #row = list([src_instance_id[0:8] + ' -> ' + dst_instance_id[0:8]] + feature_vect)
        row = list([src_instance_id[0:8]] + [dst_instance_id[0:8]] + feature_vect)
        print row
        writer.writerow(row)
f.close()
