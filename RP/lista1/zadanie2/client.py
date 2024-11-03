import grpc
import threading

import chat_pb2
import chat_pb2_grpc

def receive_messages(stub):
    for note in stub.ChatStream(chat_pb2.Empty()):
        print(f"[{note.name}]: {note.message}")

def send_messages(stub, name):
    while True:
        message = input()
        if message == "/exit":
            break
        note = chat_pb2.Note()
        note.name = name
        note.message = message
        stub.SendNote(note)

def run():
    channel = grpc.insecure_channel('localhost:50051')
    stub = chat_pb2_grpc.ChatServerStub(channel)
    name = input("Enter your username: ")
    threading.Thread(target=receive_messages, args=(stub,), daemon=True).start()
    send_messages(stub, name)

if __name__ == '__main__':
    run()
