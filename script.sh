VALUES_FILE="values.yaml"

# values.yaml dosyasının geçmişinden bir önceki commit’i bul
COMMIT_HISTORY=($(git log origin/main --pretty=format:%H -- "$VALUES_FILE"))

if [ "${#COMMIT_HISTORY[@]}" -lt 2 ]; then
  echo "⚠️  Rollback yapılamaz: $VALUES_FILE için sadece bir commit mevcut."
  exit 1
fi

PREVIOUS_COMMIT=${COMMIT_HISTORY[1]}
echo "⏪ Rollback yapılacak commit: $PREVIOUS_COMMIT"

# yq ile önceki commit'ten deploy.image.tag ve migration.image.tag değerlerini al
DEPLOY_TAG=$(git show "$PREVIOUS_COMMIT:$VALUES_FILE" | yq e '.deploy.image.tag' -)

if [ -z "$DEPLOY_TAG" ] || [ "$DEPLOY_TAG" == "null" ]; then
  echo "❌ Önceki commit'te deploy.image.tag bulunamadı."
  exit 1
fi
echo $DEPLOY_TAG
echo "✅ $SERVICE_NAME rollback başarıyla tamamlandı."

