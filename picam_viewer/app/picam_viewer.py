#!/usr/bin/python3
# coding: utf-8
# -*- coding: utf-8 -*-

from flask import Flask, render_template, request, send_from_directory
import datetime
import glob
import os
import re
import sys

###############################################################################
#
def get_dirname_photo():
    dirname = "%s/photo" % (os.environ['PICAM_DATA'])
    return dirname

###############################################################################
#
def get_filename_photo(photo_id, ext):
    dirname = get_dirname_photo()
    filename = "%s/%s%s" % (dirname, photo_id, ext)
    return filename

###############################################################################
#
def exists_photo(photo_id):
    filename = get_filename_photo(photo_id, ".jpg")
    sta = os.path.exists(filename)
    return sta

###############################################################################
#
def read_entry(fh):
    ent = {}

    while True:
        line = fh.readline()
        if not line:
            break
        elif re.match(r"\s*#", line):
            continue
        elif re.match(r"\s*$", line):
            continue
        k, v = line.rstrip().split("\t", 1)
        ent[k.lower()] = v

    return ent

###############################################################################
#
def read_photo_meta(photo_id):
    ent = {}

    #
    filename = get_filename_photo(photo_id, '.meta')
    with open(filename) as fh:
        ent = read_entry(fh)
    ent['photo_id'] = photo_id
    return ent


###############################################################################
#
def list_photo_yyyymm():
    list_photo_yyyymm = []
    dirname = get_dirname_photo()
    filepath = "%s/*" % (dirname)
    list_year = sorted(glob.glob(filepath), reverse=True)

    #
    today = datetime.date.today()
    display_last_years = 5

    #
    for fileyear in list_year:
        year = os.path.basename(fileyear)
        if (int(year) < today.year - display_last_years):
            break

        filepath = "%s/%s/*" % (dirname, year)
        list_mon = sorted(glob.glob(filepath), reverse=True)

        for filemon in list_mon:
            mon = os.path.basename(filemon)
            list_photo_yyyymm.append("%04d/%02d" % (int(year), int(mon)))

    return list_photo_yyyymm

###############################################################################
#
def list_photo(yyyymm):
    list_photo = []
    dirname = get_dirname_photo()
    filepath = "%s/%s/*.jpg" % (dirname, yyyymm)
    list_jpg = sorted(glob.glob(filepath), reverse=True)

    for filejpg in list_jpg:
        ent = {}
        photo_id, photo_ext = os.path.splitext(os.path.basename(filejpg))
        ent['photo_id'] = "%s/%s" % (yyyymm, photo_id)

        #
        dt = datetime.datetime.fromtimestamp(os.stat(filejpg).st_mtime)
        ent['photo_timestamp'] = dt.strftime("%Y-%m-%dT%H:%M:%S")

        #
        meta = read_photo_meta(ent['photo_id'])
        ent['photo_edge_id'] = meta['edge_id']

        #
        list_photo.append(ent)

    return list_photo

###############################################################################

app = Flask(__name__)

@app.route('/')
def photo_root():
    return photo_list()

@app.route('/photo/list')
def photo_list():
    args = {}
    args['list_yyyymm'] = list_photo_yyyymm()
    args['sel_yyyymm'] = request.args.get('view_year')
    if (args['sel_yyyymm'] == ""):
        args['sel_yyyymm'] = args['list_yyyymm'][0]

    #
    args['list_photo'] = list_photo(args['sel_yyyymm'])


    #
    body = render_template("photo/list.html", args=args)
    return body

@app.route('/photo/view')
def photo_view():

    # remove wrong chars
    photo_id0 = request.args.get('photo_id')
    photo_id1 = re.sub(r"[^0-9a-zA-z_\.\/\-]", "", photo_id0)
    sta = exists_photo(photo_id1)
    if (sta):
        filename = get_filename_photo(photo_id1, '.jpg')
        d = os.path.dirname(filename)
        f = os.path.basename(filename)
        return send_from_directory(d, f)

    #
    body = render_template("photo/view.html")
    return body

if __name__ == "__main__":
    port = int(os.environ['PICAM_PORT'])
    if ((port is None) or (port <= 0)):
        port = 8080
    app.run(debug=True, host='0.0.0.0', port=port)

#
