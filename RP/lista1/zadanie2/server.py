import grpc
from concurrent import futures
import threading

import chat_pb2
import chat_pb2_grpc

class ChatServer(chat_pb2_grpc.ChatServerServicer):
    def __init__(self):
        self.notes = []
        self.lock = threading.Lock()
        self.clients = []

    def ChatStream(self, request, context):
        last_index = 0
        while True:
            with self.lock:
                new_notes = self.notes[last_index:]
            for note in new_notes:
                yield note
            last_index += len(new_notes)

    def SendNote(self, request, context):
        with self.lock:
            self.notes.append(request)
        return chat_pb2.Empty()

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    chat_pb2_grpc.add_ChatServerServicer_to_server(ChatServer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("Server port: 50051")
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
