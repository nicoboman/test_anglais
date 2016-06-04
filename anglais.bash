#! /bin/bash

#-------- S'arrêter dès la première erreur ----------
set -e

#################################
# Positionnement des constantes #
#################################
. ./commun.bash
readonly C_NB_FICHIERS=46
readonly C_AFFICH_HISTO_EXEC_START=10
readonly C_AFFICH_HISTO_EXEC_AFTER_TEST=5
readonly PS3="Votre choix: "
readonly C_VERBES_IRREGULIERS=45
readonly LISTE_FICHIERS="
The_House.txt
Home_Life.txt
The_Familly.txt
Food_The_Meals.txt
Games_and_Past_times.txt
Schools_Education.txt
Science_literature_art.txt
The_human_body.txt
Health.txt
The_5_senses_and_speech.txt
Bodily_activity.txt
Games_and_sports.txt
Clothes_dress.txt
The_sky_and_the_earth.txt
Seas_and_rivers.txt
The_weather_and_the_season.txt
Time_The_calendar.txt
The_country_the_village.txt
Gardens_and_orchards.txt
The_farm_Farm_animals.txt
Agricultural_work.txt
Trees_and_forest.txt
Countries_far_and_near.txt
Towns_and_cities.txt
Callings_and_trades.txt
Industry.txt
Commerce_and_business.txt
Finance_and_Economy.txt
Travelling.txt
The_United_Kingdom.txt
The_Armed_Forces.txt
Churches_and_religion.txt
Feelings_Part_1.txt
Feelings_Part_2.txt
Human_behaviour.txt
Moral_standards.txt
Human_relations.txt
The_mind.txt
Action.txt
Will,freedom_and_habit.txt
Abstract_relations.txt
Importance_and_degree.txt
Change.txt
Literature.txt
Verbes_irreguliers.txt
Notes.txt"

###################################################################
# Fonction de calcul du nombre de mots dans un fichier de donnees #
###################################################################
function calculerNombreMots() {
local i=0

for fichier in $LISTE_FICHIERS
do
	tabNbreMots[i]=$(wc -l "${REPERTOIRE_DONNEES}""${fichier}" | sed -e 's/ .*$//')
	tabNomSujet[i]=$(echo -e "${fichier}" | sed -e 's/.txt//g' | sed -e 's/_/ /g')

	((i+=1))
done
}

###########################################
# Fonction de choix du type de traduction #
###########################################
function choisirTypeTraduction() {

local v_sujet_choisi="${1}"

if [[ "${v_sujet_choisi}" -eq "${C_VERBES_IRREGULIERS}" ]]
then
 
# Pour les verbes irreguliers, on impose le type du test a "THEME"
 v_type_test="THEME"
 echo -e "Pour les verbes irreguliers, type de traduction impose: theme"

else

  echo -e "Theme(t) - Version(v):\n"
  read v_type_test
  
    while [ -z "${v_type_test}" ]
    do
      echo -e "Entrez t pour theme ou v pour version."
      read v_type_test
    done

    while [ "${v_type_test}" != "t" -a "${v_type_test}" != "v" ]
    do
      echo -e "Entrez t pour theme ou v pour version."
      read v_type_test
    done
	
    case "${v_type_test}" in
      t) v_type_test="THEME";;
      v) v_type_test="VERSION";;
    esac
fi
}

###########################
# Fonction de fin de test #
###########################
function quitterTest() {

  local nbLignesHistoTraduc_final=$(wc -l "${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}" | sed -e 's/ .\/.*//')

  if [[ $nbLignesHistoTraduc_final -gt $nbLignesHistoTraduc_initial ]]
  then
    echo -e '\n\n\t\t\033[4;34;47m **********          REVISION DES MOTS TRADUITS          **********\033[0m\n'
    nbMotsTraduits=$(expr $nbLignesHistoTraduc_final - $nbLignesHistoTraduc_initial)
    tail -$nbMotsTraduits "${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}"
    echo -e "\n------------------------------\n"
  fi
  
  exit 0
}

#################################
# Fonction de lancement du test #
#################################
function lancerTest() {

	# Lancement du test
	"${REPERTOIRE_DONNEES}""librairieMetI.bash" "${C_LANCER_TEST}" "${v_type_test}" "${titre}"
	local cr_erreur="${?}"
	
	# Si execution ok, alors on historise le test dans le fichier des executions
	if [[ "${cr_erreur}" -eq 0 ]]
	then
		printf "%-10s%-30s%-10s\\n" "${v_type_test}" `echo "${titre}" | sed 's/.txt//g'` `date +%d/%m/%Y` >>"${REPERTOIRE_HISTO}""${FICHIER_HISTO_EXEC}"
	fi

	tail -"${C_AFFICH_HISTO_EXEC_AFTER_TEST}" "${REPERTOIRE_HISTO}""${FICHIER_HISTO_EXEC}" 
	
	# Proposition de sujet pour le test suivant
	proposerTestSuivant
}

###########################################
# Fonction de proposition du test suivant #
###########################################
function proposerTestSuivant() {

(( v_next_topic_number = REPLY+1 ))

if (( v_next_topic_number <= "${C_NB_FICHIERS}" ))
then
  v_next_topic_subject=$(echo "${tabNomSujet[$REPLY]}" | sed -e 's/ /_/g')".txt"
  v_nb_elements=$(wc -l $(find "${REPERTOIRE_DONNEES}"* -name "${v_next_topic_subject}" | grep -v "~"))
  v_nb_elements=$(echo -e "${v_nb_elements}" | sed -e 's/ \/.*//')
  echo -e "\nProposition pour l'execution suivante [Nombre total d'elements]: "${v_next_topic_number}" $(echo "${v_next_topic_subject}" | sed -e 's/_/ /g' | sed -e 's/.txt//g') [${v_nb_elements}]\n"
    
else
    echo -e "\nLa fin du menu est atteinte => pas de proposition.\n"
fi

}

##################
# Fonction Usage #
##################
function usage() {
  echo -e "\tObjet: ce script permet de reviser du vocabulaire anglais, classe par theme."
  echo -e "\tLancement du test: lancer le script anglais.bash avec l'option courte -t ou l'option longue --test"
}

######################################
# Algorithme principal: anglais.bash #
######################################
# Verification des arguments du script
while true
do
    case "${1}" in
      -t)
      break
      ;;
      --test)
      break
      ;;
      *) usage
      exit 1
      ;;
    esac
done

#########################################################################
# Creation des fichiers d'historisation s'ils n'existent pas
#-----------------------------------------------------------
if [ ! -f "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_TRADUC}" ]
then
	echo -e "\n\033[1;31;47mCreation du fichier "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_TRADUC}"\033[0m"
	touch "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_TRADUC}"
	local cr_erreur="${?}"
	
	if [[ ! "${cr_erreur}" -eq 0 ]]
	then
		echo -e "\n\033[1;31;47mCreation du fichier "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_TRADUC}" impossible => arrêt du script\033[0m"
		exit -1
	fi
fi
#-----------------------------------------------------------
if [ ! -f "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_EXEC}" ]
then
	echo -e "\n\033[1;31;47mCreation du fichier "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_EXEC}"\033[0m"
	touch "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_EXEC}"
	local cr_erreur="${?}"
	
	if [[ ! "${cr_erreur}" -eq 0 ]]
	then
		echo -e "\n\033[1;31;47mCreation du fichier "${REPERTOIRE_DONNEES}""${FICHIER_HISTO_EXEC}" impossible => arrêt du script\033[0m"
		exit -1
	fi
fi

# Controle du nombre de lignes des fichiers d'historisation
#----------------------------------------------------------
"${REPERTOIRE_DONNEES}""librairieMetI.bash" "${C_CHECK_NBLIGNES_HISTO_TRADUC}"
"${REPERTOIRE_DONNEES}""librairieMetI.bash" "${C_CHECK_NBLIGNES_HISTO_TRADUC}"

calculerNombreMots

echo -e '\n\n\t\t\033[4;34;47m **********          PRECEDENTS THEMES CHOISIS          **********\033[0m\n'

tail -"${C_AFFICH_HISTO_EXEC_START}" "${REPERTOIRE_HISTO}""${FICHIER_HISTO_EXEC}"

nbLignesHistoTraduc_initial=$(wc -l "${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}" | sed -e 's/ .\/.*//')

echo -e '\n\n\t\t\033[4;34;47m **********          MENU - MOT et IDEE          **********\033[0m'
echo -e '\t\t\033[4;34;47m **********          Faites votre choix          **********\033[0m\n'

select choix in "${tabNomSujet[0]} : ${tabNbreMots[0]}" "${tabNomSujet[1]} : ${tabNbreMots[1]}" "${tabNomSujet[2]} : ${tabNbreMots[2]}" "${tabNomSujet[3]} : ${tabNbreMots[3]}" "${tabNomSujet[4]} : ${tabNbreMots[4]}" "${tabNomSujet[5]} : ${tabNbreMots[5]}" "${tabNomSujet[6]} : ${tabNbreMots[6]}" "${tabNomSujet[7]} : ${tabNbreMots[7]}" "${tabNomSujet[8]} : ${tabNbreMots[8]}" "${tabNomSujet[9]} : ${tabNbreMots[9]}" "${tabNomSujet[10]} : ${tabNbreMots[10]}" "${tabNomSujet[11]} : ${tabNbreMots[11]}" "${tabNomSujet[12]} : ${tabNbreMots[12]}" "${tabNomSujet[13]} : ${tabNbreMots[13]}" "${tabNomSujet[14]} : ${tabNbreMots[14]}" "${tabNomSujet[15]} : ${tabNbreMots[15]}" "${tabNomSujet[16]} : ${tabNbreMots[16]}" "${tabNomSujet[17]} : ${tabNbreMots[17]}" "${tabNomSujet[18]} : ${tabNbreMots[18]}" "${tabNomSujet[19]} : ${tabNbreMots[19]}" "${tabNomSujet[20]} : ${tabNbreMots[20]}" "${tabNomSujet[21]} : ${tabNbreMots[21]}" "-> ${tabNomSujet[22]} : ${tabNbreMots[22]}" "${tabNomSujet[23]} : ${tabNbreMots[23]}" "${tabNomSujet[24]} : ${tabNbreMots[24]}" "${tabNomSujet[25]} : ${tabNbreMots[25]}" "${tabNomSujet[26]} : ${tabNbreMots[26]}" "${tabNomSujet[27]} : ${tabNbreMots[27]}" "${tabNomSujet[28]} : ${tabNbreMots[28]}" "${tabNomSujet[29]} : ${tabNbreMots[29]}" "${tabNomSujet[30]} : ${tabNbreMots[30]}" "${tabNomSujet[31]} : ${tabNbreMots[31]}" "${tabNomSujet[32]} : ${tabNbreMots[32]}" "${tabNomSujet[33]} : ${tabNbreMots[33]}" "${tabNomSujet[34]} : ${tabNbreMots[34]}" "${tabNomSujet[35]} : ${tabNbreMots[35]}" "${tabNomSujet[36]} : ${tabNbreMots[36]}" "${tabNomSujet[37]} : ${tabNbreMots[37]}" "${tabNomSujet[38]} : ${tabNbreMots[38]}" "${tabNomSujet[39]} : ${tabNbreMots[39]}" "${tabNomSujet[40]} : ${tabNbreMots[40]}" "${tabNomSujet[41]} : ${tabNbreMots[41]}" "${tabNomSujet[42]} : ${tabNbreMots[42]}" "${tabNomSujet[43]} : ${tabNbreMots[43]}" "${tabNomSujet[44]} : ${tabNbreMots[44]}" "${tabNomSujet[45]} : ${tabNbreMots[45]}" "q Quitter" 

do

if [[ "${REPLY}" != "q" ]]
then
  if [[ "${REPLY}" != "exit" ]]
  then
    if [ "${REPLY}" -ge 1 ]
    then
      if [ "${REPLY}" -le "${C_NB_FICHIERS}" ]
      then
        echo -e "\nVous avez choisi le menu "${REPLY}".\n"
        choisirTypeTraduction "${REPLY}"
      fi
    fi
  fi	
fi
  
case "${REPLY}" in
    
    1) titre="The_House.txt"
	lancerTest;;
    2) titre="Home_Life.txt"
	lancerTest;;
    3) titre="The_Familly.txt"
	lancerTest;;
    4) titre="Food_The_Meals.txt"
	lancerTest;;
    5) titre="Games_and_Past_times.txt"
	lancerTest;;
    6) titre="Schools_Education.txt"
	lancerTest;;
    7) titre="Science_literature_art.txt"
	lancerTest;;
    8) titre="The_human_body.txt"
	lancerTest;;
    9) titre="Health.txt"
	lancerTest;;
    10) titre="The_5_senses_and_speech.txt"
	lancerTest;;
    11) titre="Bodily_activity.txt"
	lancerTest;;
    12) titre="Games_and_sports.txt"
	lancerTest;;
    13) titre="Clothes_dress.txt"
	lancerTest;;
    14) titre="The_sky_and_the_earth.txt"
	lancerTest;;
    15)  titre="Seas_and_rivers.txt"
	lancerTest;;
    16)  titre="The_weather_and_the_season.txt"
	lancerTest;;
    17) titre="Time_The_calendar.txt"
	lancerTest;;
    18) titre="The_country_the_village.txt"
	lancerTest;;
    19) titre="Gardens_and_orchards.txt"
	lancerTest;;
    20) titre="The_farm_Farm_animals.txt"
	lancerTest;;
    21) titre="Agricultural_work.txt"
	lancerTest;;
    22) titre="Trees_and_forest.txt"
	lancerTest;;
    23) titre="Countries_far_and_near.txt"
	lancerTest;;
    24) titre="Towns_and_cities.txt"
	lancerTest;;
    25) titre="Callings_and_trades.txt"
	lancerTest;;
    26) titre="Industry.txt"
	lancerTest;;
    27) titre="Commerce_and_business.txt"
	lancerTest;;
    28) titre="Finance_and_Economy.txt"
	lancerTest;;
    29) titre="Travelling.txt"
	lancerTest;;
    30) titre="The_United_Kingdom.txt"
	lancerTest;;
    31) titre="The_Armed_Forces.txt"
	lancerTest;;
    32) titre="Churches_and_religion.txt"
	lancerTest;;
    33) titre="Feelings_Part_1.txt"
	lancerTest;;
    34) titre="Feelings_Part_2.txt"
	lancerTest;;
    35) titre="Human_behaviour.txt"
	lancerTest;;
    36) titre="Moral_standards.txt"
	lancerTest;;
    37) titre="Human_relations.txt"
	lancerTest;;
    38) titre="The_mind.txt"
	lancerTest;;
    39) titre="Action.txt"
	lancerTest;;
    40) titre="Will,freedom_and_habit.txt"
	lancerTest;;
    41) titre="Abstract_relations.txt"
	lancerTest;;
    42) titre="Importance_and_degree.txt"
	lancerTest;;
    43) titre="Change.txt"
	lancerTest;;
    44) titre="Literature.txt"
	lancerTest;;
    45) titre="Verbes_irreguliers.txt"
	lancerTest;;
    46) titre="Notes.txt"
	lancerTest;;
    q) quitterTest;;
    *) echo -e "Choix non valide.";;
esac

done
