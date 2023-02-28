#!/usr/bin/env python

from __future__ import with_statement

import sys
import os
import calendar
import glob
import subprocess

import cgi
import cgitb
cgitb.enable()

# gallery.cgi?mode=photo%path=/scrap/photos/2010/02/1234.jpg



# temporary config
config = {"wwwroot": "/var/www/html",
          "mediaroot": "/scrap",
          "photodir": "photos",
          "moviedir": "movies",
          "cachedir": ".gallerycache",
          "mode": "photo",
          "title": "Photo Gallery"}


toplevel_dir = os.path.join(config['mediaroot'], config['%sdir' % config['mode']])



def do_header(title=None):
    if not title:
        title=config['title']
    print "Content-Type: text/html"
    print ""
    print "<html>"
    print "<head>"
    print "<title>%s</title>" % title
    print "</head>"
    print ""
    print "<body>"
    print "<h1>%s</h1>" % title
    print "<p><hr><p>"
    print ""


def do_footer():
    print ""
    print "<p><hr></p>"
    print "</body>"
    print "</html>"
    

def do_path(full_path, shrunk, debug, page, pagesize):
    
    # figure out what to do based on path
    path = full_path[len(toplevel_dir)+1:].split(os.path.sep)

    year = None
    month = None
    pic = None

    try:
        year = path[0]
        month = path[1]
        pic = path[2]
    except:
        pass

    if pic:
        title = "%s: %s" % (config['title'], pic)
    elif month:
        try:
            month_str = calendar.month_name[int(month)]
        except:
            month_str = month
        title = "%s: %s, %s" % (config['title'], month_str, year)
        if pagesize and page:
            title += " (page %d)" % page
    elif year:
        title = "%s: %s" % (config['title'], year)
    else:
        title = config['title']
    
    do_header(title)

    if pic:
        # it's a single pic
        do_pic(full_path, debug, pagesize)

    elif month:
        # it's a dir of pics!  do the gallery!
        do_gallery(full_path, year, month, month_str, debug, page, pagesize)

    else:
        # it's an index page, generate links

        print "<table>"

        if full_path != toplevel_dir:
            print "<tr>"
            print "<td align=left><img src=../icons/back.gif></td>"
            print "<td align=left><a href=?path=%s&debug=%d&pagesize=%d>Parent Directory</a></td>" % (os.path.dirname(full_path), debug, pagesize)
            print "</tr>"

        subdirs = os.listdir(full_path)
        subdirs.sort()
        for x in subdirs:
            abs_x = os.path.join(full_path, x)
            if os.path.isdir(abs_x) and not x.startswith('.'):
                try:
                    x_str = calendar.month_name[int(x)]
                except:
                    x_str = x
                print "<tr>"
                print "<td align=left><img src=../icons/folder.gif></td>"
                print "<td align=left><a href=?path=%s&debug=%d&pagesize=%d>%s</a></td>" % (abs_x, debug, pagesize, x_str)
                if year:
                    print "<td align=left>%d %ss</td>" % (len(glob.glob("%s/*.jpg" % abs_x)), config['mode'])
                print "</tr>"

        print "</table>"
        
    do_footer()


def do_gallery(path, year, month, month_str, debug, page=1, pagesize=100):

    # update/generate cached thumbnails
    cache_thumbnails(path, debug)
    
    print "<center>"
    print "<table>"
    print "<tr>"
    print "<td align=left><img src=../icons/back.gif></td>"
    print "<td align=left><a href=?path=%s&debug=%d&pagesize=%d>Parent Directory</a></td>" % (os.path.dirname(path), debug, pagesize)
    print "</tr>"
    print "</table>"

    print "<table cellpadding=10 callspacing=10 border=5>"
    print "<tr>"

    max_col_count = 4
    col_count = 0
    all_images = glob.glob("%s/*.jpg" % path)
    all_images.sort()

    if pagesize:
        # we're going to create pages of pagesize pics, and only display the specified page
        images = all_images[(page-1)*pagesize:page*pagesize]
    else:
        images = all_images

    for image in images:
        if col_count == max_col_count:
            print "</tr>"
            print "<tr>"
            col_count = 0
        print "<td align=center>"
        thumb = os.path.join('..', config['cachedir'], 'thumb', image[1:])
        print "<a href=?path=%s&shrunk=1&debug=%d&page=%d&pagesize=%d><img src=%s></a><br>" % (image, debug, page, pagesize, thumb)
        print "<a href=?path=%s&shrunk=1&debug=%d&page=%d&pagesize=%d>medium</a>" % (image, debug, page, pagesize)
        print "<a href=?path=%s&debug=%d&page=%d&pagesize=%d>huge</a>" % (image, debug, page, pagesize)
        print "</td>"
        col_count += 1

    print "</table>"

    if pagesize:
        if page == 1:
            print "previous page"
        else:
            print "<a href=?path=%s&debug=%d&page=%d&pagesize=%d>previous page</a>" % (path, debug, page-1, pagesize)
        print "|"

        number_of_pages, x = divmod(len(all_images), pagesize)
        if x:
            # always round up
            number_of_pages += 1

        for x in range(number_of_pages):
            x+=1
            if x == page:
                print "<b>%d</b> |" % x
            else:
                print "<a href=?path=%s&debug=%d&page=%d&pagesize=%d>%d</a> |" % (path, debug, x, pagesize, x)

        if images[-1] == all_images[-1]:
            print "next page"
        else:
            print "<a href=?path=%s&debug=%d&page=%d&pagesize=%d>next page</a>" % (path, debug, page+1, pagesize)

    print "</center>"


def do_pic(path, debug, pagesize):
    """
    this function is going to create an html page displaying the
    provided pic with next/previous links
    """
    
    cache_shrunken(path, debug)

    shrunk = os.path.join('..', config['cachedir'], 'shrunk', path[1:])
    
    otherpics = glob.glob("%s/*.jpg" % os.path.dirname(path))
    otherpics.sort()

    i = otherpics.index(path)
    page = int(i/pagesize)+1

    try:
        next = otherpics[i+1]
        next = "<a href=?path=%s&shrunk=1&debug=%d&pagesize=%d>next</a>" % (next, debug, pagesize)
    except:
        next = "next"

    try:
        if i == 0:
            # we have to do this becase python lists automatically
            # wrap around to the end with negative values...
            raise Exception
        previous = otherpics[i-1]
        previous = "<a href=?path=%s&shrunk=1&debug=%d&pagesize=%d>previous</a>" % (previous, debug, pagesize)
        
    except:
        previous = "previous"

    print "<center>"
    print "<table cellpadding=10 callspacing=10 border=5>"
    print ""
    print "<tr>"
    print "<td align=center>"
    print "<a href=?path=%s&debug=%d&pagesize=%d><img src=%s></a><br>" % (path, debug, pagesize, shrunk)
    print previous
    print "||"
    print "<a href=?path=%s&debug=%d&page=%d&pagesize=%d>index</a>" % (os.path.dirname(path), debug, page, pagesize)
    print "||"
    print next
    print "</td>"
    print "</tr>"
    print "</table>"
    print "</center>"


def cache_thumbnails(path, debug):
    """
    this function is going to create thumbnails of all the jpgs in
    path in our configured cach dir.  thumbnails are only created if
    source image is newer than existing thumbnail (or there isn't a
    thumbnail at all).
    """
    for x in glob.glob("%s/*.jpg" % path):
        cached_x = os.path.join(config['wwwroot'], config['cachedir'], 'thumb', x[1:])
        #print cached_x, "<br>"
        try:
            if os.path.getmtime(cached_x) > os.path.getmtime(x):
                continue
        except:
            # cache file must not exist, let's create it
            pass
        
        try:
            os.makedirs(os.path.dirname(cached_x))
        except:
            pass

        # this uses ImageMagick's convert program
        go = ['convert', '-size', '120x120', x, '-resize', '120x120', '+profile', '"*"', cached_x]
        if debug:
            print go, '<br>'
        subprocess.check_call(go)


def cache_shrunken(img, debug):
    """
    this function is going to create a shrunken image of the supplied
    jpg in our configured cache dir.  shrunken pic is only created if
    source image is newer than existing shrunken image.
    """
    cached_img = os.path.join(config['wwwroot'], config['cachedir'], 'shrunk', img[1:])
    try:
        if os.path.getmtime(cached_img) > os.path.getmtime(img):
            return
    except:
        # cache file must not exist, let's create it
        pass

    try:
        os.makedirs(os.path.dirname(cached_img))
    except:
        pass

    # this uses ImageMagick's convert program
    go = ['convert', '-size', '640x640', img, '-resize', '640x640', '+profile', '"*"', cached_img]
    if debug:
        print go, '<br>'
    subprocess.check_call(go)




if __name__ == "__main__":
    form = cgi.FieldStorage()

    full_path = form.getfirst('path', toplevel_dir)
    shrunk = int(form.getfirst('shrunk', '0'))
    debug = int(form.getfirst('debug', '0'))
    page = int(form.getfirst('page', '1'))
    pagesize = int(form.getfirst('pagesize', '0'))

    if full_path.endswith(".jpg") and not shrunk:
        print "Content-Type: image/jpeg"
        print ""
        with open(full_path) as f:
            sys.stdout.write(f.read())

    else:
        do_path(full_path, shrunk, debug, page, pagesize)
