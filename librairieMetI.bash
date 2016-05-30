#! /bin/bash

#################################
# Positionnement des constantes #
#################################
. ./commun.bash
readonly C_NB_MAX_LIGNES_TRADUC=500
readonly C_NB_MAX_LIGNES_EXEC=200

#######################
# Demarrage du script #
#######################
case "${1}" in

################################################
# Nettoyage du fichier d'histo des traductions #
################################################
"${C_CHECK_NBLIGNES_HISTO_TRADUC}" | "${C_CHECK_NBLIGNES_HISTO_EXEC}")
if [[ "${1}" = "${C_CHECK_NBLIGNES_HISTO_TRADUC}" ]]
then
	v_fichier="${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}"
	v_seuil_lignes="${C_NB_MAX_LIGNES_TRADUC}"
	v_libelle_info="\nINFO: le fichier d'histo des traductions comporte plus de 500 lignes.\nSouhaitez-vous faire une RAZ de ce fichier? (o/n)\n"
	v_libelle_raz_ko="Pb lors de la mise aÂ  jour du fichier d'histo des traductions.\nArret du script.\n"
	v_libelle_raz_ok="RAZ du fichier d'histo des traductions: OK\n"
else
	v_fichier="${REPERTOIRE_HISTO}""${FICHIER_HISTO_EXEC}"
	v_seuil_lignes="${C_NB_MAX_LIGNES_EXEC}"
	v_libelle_info="\nINFO: le fichier d'histo des executions comporte plus de 200 lignes.\nSouhaitez-vous faire une RAZ de ce fichier? (o/n)\n"
	v_libelle_raz_ko="Pb lors de la mise aÂ  jour du fichier d'histo des executions.\nArret du script.\n"
	v_libelle_raz_ok="RAZ du fichier d'histo des executions: OK\n"
fi

if [[ $(cat "${v_fichier}" | wc -l) -gt "${v_seuil_lignes}" ]]
then
	echo -e "${v_libelle_info}"
 	read
    	if [[ "${REPLY}" = "o" ]]
    	then
	rm "${v_fichier}"
		if [[ "${?}" -ne 0 ]]
		then
		echo -e "${v_libelle_raz_ko}"
		exit 1
		fi
		
	touch "${v_fichier}"
		if [[ "${?}" -ne 0 ]]
		then
		echo -e "${v_libelle_raz_ko}"
		exit 1
		else
		echo -e "${v_libelle_raz_ok}"
		fi
	fi
fi
;;

#####################
# Lancement du test #
#####################
"${C_LANCER_TEST}")
v_type_test="${2}"
v_sujet="${3}"

echo -e "\n\t\t\033[4;34;47m **********          Debut test: "${v_sujet}"          **********\033[0m\n"

v_nb_mots=$(wc -l "$REPERTOIRE_DONNEES""$v_sujet" | sed -e 's/ .*//g')

echo -e "Le fichier comprend ${v_nb_mots} elements."
echo -e "Entrez le nombre d occurences souhaite:[Nombre total d elements]"
read v_nb_occurences

if [[ "${v_nb_occurences}" == "" ]]
  then
    v_nb_occurences="${v_nb_mots}"
fi

# Constitution du tableau d'indices alÃ©atoires:
#----------------------------------------------
i=0
compteurNbMotsTraduits=0

while ((i<v_nb_occurences))
do
	index_aleatoire=$((RANDOM%$v_nb_mots))
	((index_aleatoire+=1))

		for element in ${tab_aleatoire[*]}
		do

			if [[ $index_aleatoire -eq $element ]]
			then
				continue 2
			fi
		done
	tab_aleatoire[i]=$index_aleatoire
	((i+=1))
done

# Test:
#------
i=0

while ((i<v_nb_occurences))
do
	index_aleatoire=${tab_aleatoire[$i]}

   	echo -e "\n------------------------------"
	
	if [[ $v_type_test == "THEME" ]]
	then
		sed -n ''$index_aleatoire'p' "${REPERTOIRE_DONNEES}""${v_sujet}" | cut -d";" -f2 | sed 's/^[	 ]*//'
	else
		sed -n ''$index_aleatoire'p' "${REPERTOIRE_DONNEES}""${v_sujet}" | cut -d";" -f1 | sed 's/^[	 ]*//'
	fi
	
  	echo -e "$(expr $i + 1)/$v_nb_occurences - 't' pour traduction - 'q' pour quitter:"
  	read
    	if [[ "${REPLY}" = "q" ]]
    	then
    	break
    	fi
    	if [[ "${REPLY}" = "t" ]]
    	then

    	echo -e "Traduction:"

	if [[ $v_type_test == "THEME" ]]
	then
		v_mot_traduit=$(sed -n ''$index_aleatoire'p' $REPERTOIRE_DONNEES$v_sujet | cut -d";" -f1 | sed 's/^[	 ]*//')
	else
		v_mot_traduit=$(sed -n ''$index_aleatoire'p' $REPERTOIRE_DONNEES$v_sujet | cut -d";" -f2 | sed 's/^[	 ]*//')
	fi

	echo -e "\n\033[1;31;47m${v_mot_traduit}\033[0m"

	v_traduc_anglais=$(sed -n ''$index_aleatoire'p' $REPERTOIRE_DONNEES$v_sujet | cut -d";" -f2 | sed 's/^[	 ]*//'| sed 's/ /_/g' | sed 's/_$//g')
	v_traduc_francais=$(sed -n ''$index_aleatoire'p' $REPERTOIRE_DONNEES$v_sujet | cut -d";" -f1 | sed 's/^[	 ]*//'| sed 's/ /_/g' | sed 's/_$//g')
	printf "%-30s-----%30s\n" $v_traduc_anglais $v_traduc_francais>>"${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}"

	((compteurNbMotsTraduits+=1))

    	echo -e "------------------------------\n"
    	fi	

((i+=1))

done

echo -e "\n\t\t\033[4;34;47m **********          Fin test : "${v_sujet}"         **********\033[0m\n"


if [[ "${compteurNbMotsTraduits}" -gt 0 ]]
then
echo -e "Souhaitez-vous revoir les mots traduits? [oui] - n pour NON"
read
	if [[ "${REPLY}" != "n" ]]
	then
	echo -e "\n------------------------------\n"
	tail -"${compteurNbMotsTraduits}" "${REPERTOIRE_HISTO}""${FICHIER_HISTO_TRADUC}"
	echo -e "\n------------------------------\n"
	fi
fi

;;

esac
