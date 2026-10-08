#!/bin/bash
#<!-- Copyright (c) 2026 ortipik - Licence MIT (voir fichier LICENSE) -->
#-----------------------------------------------------------------------
# ce script a été élaboré par Ortipik pour OMEGA-server.
# https://kraynux.snake-mackarel.ts.net
#-----------------------------------------------------------------------

echo "📊 STATISTIQUES COMPLÈTES DU SITE"
echo "=================================="
echo ""

# 1. Nombre total de fichiers (TOUTES extensions)
total_files=$(find . -type f | wc -l)
echo "📁 Total fichiers (toutes extensions): $total_files"

# 2. Détail par extension
echo ""
echo "📄 DÉTAIL PAR EXTENSION"
echo "----------------------"
echo "   HTML: $(find . -name "*.html" -type f | wc -l)"
echo "   PHP: $(find . -name "*.php" -type f | wc -l)"
echo "   CSS: $(find . -name "*.css" -type f | wc -l)"
echo "   JS: $(find . -name "*.js" -type f | wc -l)"
echo "   TXT: $(find . -name "*.txt" -type f | wc -l)"
echo "   PDF: $(find . -name "*.pdf" -type f | wc -l)"
echo "   Images: $(find . -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.svg" -o -name "*.webp" \) 2>/dev/null | wc -l)"
echo "   Autres: $(find . -type f ! -name "*.html" ! -name "*.php" ! -name "*.css" ! -name "*.js" ! -name "*.txt" ! -name "*.pdf" ! -name "*.jpg" ! -name "*.jpeg" ! -name "*.png" ! -name "*.gif" ! -name "*.svg" ! -name "*.webp" | wc -l)"

# 3. Taille totale
total_size=$(find . -type f -exec du -b {} + 2>/dev/null | awk '{sum+=$1} END {print sum}')
echo ""
echo "💾 Taille totale: $(numfmt --to=iec $total_size 2>/dev/null || echo "$total_size bytes")"

# 4. Extraire TOUS les liens des fichiers HTML
tmp_links=$(mktemp)
find . -name "*.html" -type f -exec grep -hoE '(href|src|action)=["'\'']([^"'\'']+)["'\'']' {} \; 2>/dev/null | \
sed 's/.*=["'\'']//; s/["'\'']$//' | \
grep -v '^$' > "$tmp_links"

total_links=$(cat "$tmp_links" | wc -l)

# 5. Statistiques des liens
echo ""
echo "🔗 STATISTIQUES DES LIENS"
echo "-------------------------"
echo "Total liens trouvés: $total_links"

# Liens internes (ne commencent pas par http, https ou //)
internal=$(grep -v '^http\|^https\|^//' "$tmp_links" | wc -l)
# Liens externes (commencent par http, https ou //)
external=$(grep -E '^http|^https|^//' "$tmp_links" | wc -l)

echo "   ✅ Liens internes: $internal"
echo "   🌐 Liens externes: $external"

# Pourcentage
if [ $total_links -gt 0 ]; then
    echo "   📊 % interne: $((internal * 100 / total_links))%"
    echo "   📊 % externe: $((external * 100 / total_links))%"
fi

# 6. Types de liens internes
echo ""
echo "📁 DÉTAIL DES LIENS INTERNES"
echo "---------------------------"

# Liens absolus (commencent par /)
abs_links=$(grep -v '^http\|^https\|^//' "$tmp_links" | grep '^/' | wc -l)
# Liens relatifs (ne commencent pas par /)
rel_links=$(grep -v '^http\|^https\|^//' "$tmp_links" | grep -v '^/' | wc -l)
# Liens vers fichiers spécifiques
links_html=$(grep -v '^http\|^https\|^//' "$tmp_links" | grep '\.html' | wc -l)
links_pdf=$(grep -v '^http\|^https\|^//' "$tmp_links" | grep '\.pdf' | wc -l)
links_txt=$(grep -v '^http\|^https\|^//' "$tmp_links" | grep '\.txt' | wc -l)
links_images=$(grep -v '^http\|^https\|^//' "$tmp_links" | grep -E '\.(jpg|jpeg|png|gif|svg|webp)' | wc -l)

echo "   - Chemins absolus (commencent par /): $abs_links"
echo "   - Chemins relatifs: $rel_links"
echo ""
echo "   - Liens vers .html: $links_html"
echo "   - Liens vers .pdf: $links_pdf"
echo "   - Liens vers .txt: $links_txt"
echo "   - Liens vers images: $links_images"

# 7. Liens externes par domaine
echo ""
echo "🌐 TOP 10 DOMAINES EXTERNES"
echo "--------------------------"

grep -E '^https?://' "$tmp_links" | \
sed -E 's#https?://([^/]+).*#\1#' | \
sort | uniq -c | sort -rn | head -10 | \
while read count domain; do
    echo "   - $domain: $count liens"
done

# 8. Liens cassés (404) - UNIQUEMENT INTERNES
echo ""
echo "❌ LIENS CASSÉS (404)"
echo "---------------------"

broken=0
broken_list=$(mktemp)

grep -v '^http\|^https\|^//' "$tmp_links" | sort -u | while read url; do
    clean=$(echo "$url" | cut -d'?' -f1 | cut -d'#' -f1)
    [ -z "$clean" ] && continue
    
    # Gérer les chemins absolus et relatifs
    if [[ "$clean" == /* ]]; then
        if [ ! -e ".$clean" ]; then
            echo "$clean" >> "$broken_list"
        fi
    else
        # Chercher le fichier par son nom
        filename=$(basename "$clean")
        found=$(find . -type f -name "$filename" 2>/dev/null | head -1)
        if [ -z "$found" ]; then
            # Vérifier aussi le chemin relatif exact
            if [ ! -e "./$clean" ]; then
                echo "$clean" >> "$broken_list"
            fi
        fi
    fi
done

broken_count=$(cat "$broken_list" 2>/dev/null | wc -l)
echo "Total liens cassés: $broken_count"

# Afficher les 20 premiers liens cassés
if [ $broken_count -gt 0 ]; then
    echo ""
    echo "🔴 Exemples de liens cassés (20 premiers):"
    head -20 "$broken_list" | while read link; do
        echo "   - $link"
    done
    if [ $broken_count -gt 20 ]; then
        echo "   ... et $((broken_count - 20)) autres"
    fi
fi

# 9. Autres types de liens
echo ""
echo "🔗 AUTRES STATISTIQUES"
echo "----------------------"
echo "   - Liens vers ancres (#): $(grep '#' "$tmp_links" | wc -l)"
echo "   - Liens mailto: $(grep '^mailto:' "$tmp_links" | wc -l)"
echo "   - Liens tel: $(grep '^tel:' "$tmp_links" | wc -l)"
echo "   - Liens javascript: $(grep '^javascript:' "$tmp_links" | wc -l)"

# 10. Liens vides ou sans valeur
echo "   - Liens vides (href=\"\"): $(grep '^["'\'']$' "$tmp_links" | wc -l)"

# 11. Top 10 fichiers avec le plus de liens
echo ""
echo "📃 TOP 10 FICHIERS AVEC LE PLUS DE LIENS"
echo "----------------------------------------"

find . -name "*.html" -type f -exec sh -c 'echo "$(grep -oE "(href|src|action)=["'\'']([^"'\'']+)["'\'']" "$1" 2>/dev/null | wc -l) $1"' _ {} \; | \
sort -rn | head -10 | \
while read count file; do
    echo "   - $count liens: $file"
done

# 12. Résumé final
echo ""
echo "📊 RÉSUMÉ FINAL"
echo "================"
echo "✅ Fichiers total: $total_files"
echo "✅ Fichiers HTML: $(find . -name "*.html" -type f | wc -l)"
echo "✅ Liens internes: $internal"
echo "✅ Liens externes: $external"
echo "❌ Liens cassés: $broken_count"
echo "📊 Taux de liens cassés: $(awk "BEGIN {printf \"%.2f%%\", ($broken_count/$internal)*100}" 2>/dev/null || echo "0%")"

# Nettoyer
rm -f "$tmp_links" "$broken_list"

#fin du script
