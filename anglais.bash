#! /bin/bash

#################################
# Positionnement des constantes #
#################################
readonly C_CHECK_NBLIGNES_HISTO_TRADUC=0
readonly C_CHECK_NBLIGNES_HISTO_EXEC=1
readonly C_LANCER_TEST=2

readonly REPERTOIRE_DONNEES="/home/nicolas/MetI/Donnees/"
readonly REPERTOIRE_HISTO="/home/nicolas/MetI/Histo/"
readonly FICHIER_HISTO_TRADUC="histo_traduc.txt"
readonly FICHIER_HISTO_EXEC="histo_exec.txt"

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
Notes.txt
"

#########################################################################
# Sous-programme de calcul du nombre de mots dans le fichier de donnees #
#########################################################################
ssp_calculNombreMots() {
local i=0

for fichier in $LISTE_FICHIERS
do
	tabNbreMots[i]=$(wc -l "${REPERTOIRE_DONNEES}""${fichier}" | sed -e 's/ .*$//')
	tabNomSujet[i]=$(echo -e "${fichier}" | sed -e 's/.txt//g' | sed -e 's/_/ /g')

	((i+=1))
done
}

#################################################
# Sous-programme de choix du type de traduction #
#################################################
ssp_choixTypeTraduc() {

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

#################################
# Sous-programme de fin de test #
#################################
ssp_quitterTest() {

  local nbLignesHistoTraduc_final=$(wc -l "${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}" | sed -e 's/ \/.*//')

  if [[ $nbLignesHistoTraduc_final -gt $nbLignesHistoTraduc_initial ]]
  then
    echo -e '\n\n\t\t\033[4;34;47m **********          REVISION DES MOTS TRADUITS          **********\033[0m\n'
    nbMotsTraduits=$(expr $nbLignesHistoTraduc_final - $nbLignesHistoTraduc_initial)
    tail -$nbMotsTraduits "${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}"
    echo -e "\n------------------------------\n"
  fi
  
  exit 0
}

#######################################
# Sous-programme de lancement du test #
#######################################
ssp_lanceTest() {

	# Lancement du test
	bash ${HOME}/bin/librairieMetI.bash "${C_LANCER_TEST}" "${v_type_test}" "${titre}"
	local cr_erreur="${?}"
	
	# Si execution ok, alors on historise le test dans le fichier des executions
	if [[ "${cr_erreur}" -eq 0 ]]
	then
		printf "%-10s%-30s%-10s\\n" "${v_type_test}" `echo "${titre}" | sed 's/.txt//g'` `date +%d/%m/%Y` >>"${REPERTOIRE_HISTO}""${FICHIER_HISTO_EXEC}"
	fi

	
	tail -"${C_AFFICH_HISTO_EXEC_AFTER_TEST}" "${REPERTOIRE_HISTO}""${FICHIER_HISTO_EXEC}" 
	
	# Proposition de sujet pour le test suivant
	ssp_nextTest
}

#################################################
# Sous-programme de proposition du test suivant #
#################################################
ssp_nextTest() {

(( v_next_topic_number = REPLY+1 ))

if (( v_next_topic_number <= "${C_NB_FICHIERS}" ))
then
  v_next_topic_subject=$(echo ${tabNomSujet[$REPLY]} | sed -e 's/ /_/g')".txt"
  v_nb_elements=$(wc -l $(find "${REPERTOIRE_DONNEES}"* -name "${v_next_topic_subject}" | grep -v "~"))
  v_nb_elements=$(echo -e "${v_nb_elements}" | sed -e 's/ \/.*//')
  echo -e "\nProposition pour l'execution suivante [Nombre total d'elements]: "${v_next_topic_number}" $(echo "${v_next_topic_subject}" | sed -e 's/_/ /g' | sed -e 's/.txt//g') [${v_nb_elements}]\n"
    
else
    echo -e "\nLa fin du menu est atteinte => pas de proposition.\n"
fi

}

######################################
# Algorithme principal: anglais.bash #
######################################

bash ${HOME}/bin/librairieMetI.bash "${C_CHECK_NBLIGNES_HISTO_TRADUC}"

bash ${HOME}/bin/librairieMetI.bash "${C_CHECK_NBLIGNES_HISTO_EXEC}"

ssp_calculNombreMots

echo -e '\n\n\t\t\033[4;34;47m **********          PRECEDENTS THEMES CHOISIS          **********\033[0m\n'

tail -"${C_AFFICH_HISTO_EXEC_START}" "${REPERTOIRE_HISTO}""${FICHIER_HISTO_EXEC}"

nbLignesHistoTraduc_initial=$(wc -l "${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}" | sed -e 's/ \/.*//')

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
        ssp_choixTypeTraduc "${REPLY}"
      fi
    fi
  fi	
fi
  
case "${REPLY}" in
    
    1) titre="The_House.txt"
	ssp_lanceTest;;
    2) titre="Home_Life.txt"
	ssp_lanceTest;;
    3) titre="The_Familly.txt"
	ssp_lanceTest;;
    4) titre="Food_The_Meals.txt"
	ssp_lanceTest;;
    5) titre="Games_and_Past_times.txt"
	ssp_lanceTest;;
    6) titre="Schools_Education.txt"
	ssp_lanceTest;;
    7) titre="Science_literature_art.txt"
	ssp_lanceTest;;
    8) titre="The_human_body.txt"
	ssp_lanceTest;;
    9) titre="Health.txt"
	ssp_lanceTest;;
    10) titre="The_5_senses_and_speech.txt"
	ssp_lanceTest;;
    11) titre="Bodily_activity.txt"
	ssp_lanceTest;;
    12) titre="Games_and_sports.txt"
	ssp_lanceTest;;
    13) titre="Clothes_dress.txt"
	ssp_lanceTest;;
    14) titre="The_sky_and_the_earth.txt"
	ssp_lanceTest;;
    15)  titre="Seas_and_rivers.txt"
	ssp_lanceTest;;
    16)  titre="The_weather_and_the_season.txt"
	ssp_lanceTest;;
    17) titre="Time_The_calendar.txt"
	ssp_lanceTest;;
    18) titre="The_country_the_village.txt"
	ssp_lanceTest;;
    19) titre="Gardens_and_orchards.txt"
	ssp_lanceTest;;
    20) titre="The_farm_Farm_animals.txt"
	ssp_lanceTest;;
    21) titre="Agricultural_work.txt"
	ssp_lanceTest;;
    22) titre="Trees_and_forest.txt"
	ssp_lanceTest;;
    23) titre="Countries_far_and_near.txt"
	ssp_lanceTest;;
    24) titre="Towns_and_cities.txt"
	ssp_lanceTest;;
    25) titre="Callings_and_trades.txt"
	ssp_lanceTest;;
    26) titre="Industry.txt"
	ssp_lanceTest;;
    27) titre="Commerce_and_business.txt"
	ssp_lanceTest;;
    28) titre="Finance_and_Economy.txt"
	ssp_lanceTest;;
    29) titre="Travelling.txt"
	ssp_lanceTest;;
    30) titre="The_United_Kingdom.txt"
	ssp_lanceTest;;
    31) titre="The_Armed_Forces.txt"
	ssp_lanceTest;;
    32) titre="Churches_and_religion.txt"
	ssp_lanceTest;;
    33) titre="Feelings_Part_1.txt"
	ssp_lanceTest;;
    34) titre="Feelings_Part_2.txt"
	ssp_lanceTest;;
    35) titre="Human_behaviour.txt"
	ssp_lanceTest;;
    36) titre="Moral_standards.txt"
	ssp_lanceTest;;
    37) titre="Human_relations.txt"
	ssp_lanceTest;;
    38) titre="The_mind.txt"
	ssp_lanceTest;;
    39) titre="Action.txt"
	ssp_lanceTest;;
    40) titre="Will,freedom_and_habit.txt"
	ssp_lanceTest;;
    41) titre="Abstract_relations.txt"
	ssp_lanceTest;;
    42) titre="Importance_and_degree.txt"
	ssp_lanceTest;;
    43) titre="Change.txt"
	ssp_lanceTest;;
    44) titre="Literature.txt"
	ssp_lanceTest;;
    45) titre="Verbes_irreguliers.txt"
	ssp_lanceTest;;
    46) titre="Notes.txt"
	ssp_lanceTest;;
    q) ssp_quitterTest;;
    *) echo -e "Choix non valide.";;
esac

done
