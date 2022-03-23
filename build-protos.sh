cd $(dirname "${BASH_SOURCE[0]}")
cd ./lib/protos
for i in *.proto; do
    echo $i
    # protoc --dart_out=grpc:../generated/google/protobuf/ -I/usr/local/include/google/protobuf/ any.proto
    protoc --dart_out=grpc:../generated -I`pwd` $i 
done



