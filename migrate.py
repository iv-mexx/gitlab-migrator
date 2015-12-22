#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
1. call: faslane list_projects
2. get list of not migrated projects and list of migrated projects
3. migrate not migrated projects
"""

import subprocess
import argparse

def getParserArgs():
    parser = argparse.ArgumentParser(
        description='Migrate one Gitlab-server (src_server) to another Gitlab-server')
    parser.add_argument("-m", "--merge", action='store_true', help='migrate projects')
    parser.add_argument("-f", "--file", default="list_projects.txt",
                        help='filename containing a list of projects in src_server')
    args = parser.parse_args()
    return args

def get_projects(f):
    """
    get list of projects and return 4 variables:
        1. List of not migrated projects
        2. List of migrated projects
        3. Count of not migrated projects
        4. Count of migrated projects
    """
    start_not_migrated = 0 # find line for not migrated projects
    start_migrated = 0 # find line for migrated projects
    count_not_migrated = 0
    count_migrated = 0

    projects = []
    migrated_projects = []

    for line in f:
        if "not yet migrated" in line:
            start_not_migrated = 1
            continue

        if "been migrated" in line:
            start_migrated = 1
            continue

        project = line.split(" ")[-1].strip("\n")

        if start_migrated and not project:
            break

        if start_not_migrated and start_migrated:
            start_not_migrated = 0

        if start_not_migrated:
            print "\t⚠️  not migrated project:", project
            projects.append(project)
            count_not_migrated += 1

        if start_migrated:
            start_not_migrated = 0
            print "\t✅  migrated project    :", project
            migrated_projects.append(project)
            count_migrated += 1

    return projects, migrated_projects, count_not_migrated, count_migrated

def merge_projects(projects):
    """
    merge projects
    """
    for project in projects:
        cmd = ("fastlane migrate project:%s"%project).split()
        subprocess.call(cmd)

if __name__ == "__main__":
    Args = getParserArgs()
    filename = Args.file
    list_projects_cmd = "fastlane list_projects".split()
    merge = Args.merge

    # redirect results of list_projects_cmd to filename
    with open(filename, "w") as F:
        subprocess.call(list_projects_cmd, stdout=F)

    with open(filename) as F:
        Projects, Migrated_projects, Count_not_migrated, Count_migrated = get_projects(F)

    print "\nSummary:"
    print "⚠️  %d not migrated projects."%Count_not_migrated
    print "✅  %d migrated projects."%Count_migrated

    if merge:
        print "merge ", merge
        merge_projects(Projects)


