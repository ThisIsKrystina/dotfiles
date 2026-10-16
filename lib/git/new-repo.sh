#!/bin/bash

#regex patterns for text replacement
repo_tag="{+REPO_NAME}+"
project_tag="{+PROJECT_NAME}+"
section_start="^\<\!\S+\s*START\s*\w*\s*\S+$"
# Add END 
section_close="/END\s\b\s*\S+\>$/gm"
