cd $(dirname "${BASH_SOURCE[0]}")
cd ./lib/protos
for i in *.proto; do
    echo ls
    protoc --dart_out=grpc:../generated -I. $i
done



