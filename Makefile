help:
	@echo "submodules    Get submodules"
	@echo "update_forks  Sync upstream formulas"
	@echo "muconfig      Re-generate .mu_repo with all formulas on Github"
	@echo "mrconfig      Re-generate .mrconfig with all formulas on Github"
	@echo "remote_gerrit Add git remote gerrit"
	@echo "remote_github Add git remote github"
	@echo "set_push      Set custom push_url"


FORKED_FORMULAS_DIR=formulas
FORMULAS=`. pipenv run python3 -c 'import sys; sys.path.append("scripts");from update_mrconfig import *; print(*get_org_repos(make_github_agent(), "saltstack-formulas"), sep="\n")'| egrep '\-formula' | sed -e 's/-formula//' `

pull:
	git pull --rebase

submodules: pull
	git submodule init
	git submodule update

muconfig: muupdate
	touch .mu_repo
	mu group add saltstack-formulas --empty
	mu register formulas/*

muupdate: update_forks
	@mu checkout master
	@mu pull

mrupdate: submodules
	# TODO: safe set-url push origin on update target
	#(for formula in formulas/*; do FORMULA=`basename $$formula` && cd $$formula && git remote set-url --push origin git@github.com:saltstack-formulas/$$FORMULA-formula.git && cd ../..; done)
	mr --trust-all -j4 run git checkout master
	mr --trust-all -j4 update

mrrelease:
	mr --trust-all -j4 run make release-major

mrconfig:
	./scripts/update_mrconfig.py

html:
	make -C doc html

pdf:
	make -C doc latexpdf

set_push:
	(for formula in $${FORMULAS_DIR:-$(FORKED_FORMULAS_DIR)}/*; do FORMULA=`basename $$formula` && cd $$formula && git remote set-url --push origin git@github.com:saltstack-formulas/$$FORMULA-formula.git && cd ../..; done)

scripts_prerequisites:
	@if ! which pipenv; then echo "Please install pipenv first";  exit 2; fi
	@pipenv --venv || pipenv --three
	@pipenv install

list: scripts_prerequisites
	@echo $(FORMULAS)

update_forks: scripts_prerequisites
	@mkdir -p $(FORKED_FORMULAS_DIR)
	@for FORMULA in $(FORMULAS) ; do\
     test -e $(FORKED_FORMULAS_DIR)/$$FORMULA || git clone  https://github.com/saltstack-formulas/$$FORMULA-formula.git $(FORKED_FORMULAS_DIR)/$$FORMULA;\
   done;

GERRIT_REMOTE_URI=
remote_gerrit: FORMULAS_DIR=$(FORKED_FORMULAS_DIR)
remote_gerrit: remote_gerrit_add

remote_gerrit_add:
	@#(for formula in $(FORMULAS_DIR)/*; do FORMULA=`basename $$formula` && cd $$formula && git remote remove gerrit || true && cd ../.. ; done)
	@mkdir -p $(FORMULAS_DIR)
	@ID=$${GERRIT_USERNAME:-$$USER};\
   for FORMULA in `ls $(FORMULAS_DIR)/`; do\
     cd $(FORMULAS_DIR)/$$FORMULA > /dev/null;\
     if ! git remote | grep gerrit 2>&1 > /dev/null ; then\
       git remote add gerrit ssh://$$ID@$(GERRIT_REMOTE_URI)/$$FORMULA;\
     fi;\
     cd - > /dev/null;\
     done;

remote_github: FORMULAS_DIR=$(FORKED_FORMULAS_DIR)
remote_github: remote_github_add

remote_github_add:
	@mkdir -p $(FORMULAS_DIR)
	@ID=$${GITHUB_USERNAME:-$$USER};\
   for FORMULA in `ls $(FORMULAS_DIR)/`; do\
     cd $(FORMULAS_DIR)/$$FORMULA > /dev/null;\
     if ! git remote | grep $$ID 2>&1 > /dev/null ; then\
       git remote add $$ID git://github.com/$$ID/$$FORMULA-formula;\
     fi;\
     d - > /dev/null;\
     done;
