# walker interact {
#     can return_message with `root entry {
#         report {
#             "response": "Hello, world!"
#         };
#     }
# }

# walker interact_with_body {
#     has name: str;

#     can return_message with `root entry {
#         report {
#             "response": "Hello, " + self.name + "!"
#         };
#     }
# }

# # New walker that reverses a string
# walker reverse_string{
#     has input: str;

#     can return_message with `root entry{
#         reversed = self.input[::-1];
#         report {
#             "response": "The reverse of '" + self.input + "' is: '" + reversed + "'"
#         };
#     }
# }
# # New Walker that calculates the sum of two numbers
# walker calculate_sum {
#     has num1: int;
#     has num2: int;

#     can return_message with `root entry {
#         result = self.num1 + self.num2;
#         report {
#             "response": "The sum of " + str(self.num1) + " and " + str(self.num2) + " is: " + str(result)
#         };
#     }
# }

import:py from mtllm.llms {Ollama}
import:jac from rag{RagEngine}


glob llm = Ollama(model_name='llama3.1');
# glob llm = Ollama(model_name='phi3.5');
glob rag_engine:RagEngine = RagEngine();
# "Session" is node in our graph that stores the chat history and status of the session.
node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1; # Tracks the state of the session 

    can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
    llm_chat(
        message:'current message':str,
        chat_history: 'chat history':list[dict],
        agent_role:'role of the agent responding':str,
        context:'retrieved context from documents':list
    ) -> 'response':str by llm();
}

walker interact {
    has message: str;
    has session_id: str;

    # ability: Initializes a session based on the session ID. 
    # If the session does not exist, it creates a new session node. Note that this ability is triggered on root entry. 
    # In every graph, there is a special node called root that serves as the starting point for the graph.
    #  A walker can be spawned on and traverse to any node in the graph. 
    # It does NOT have to start at the root node, but it can be spawned on the root node to start the traversal.
    can init_session with `root entry {
         visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[], status=1);
            print("Session Node Created");

            visit session_node;
        }
    }

# Logic flow:
# The user's message is added to the chat history.
# The RAG engine retrieves candidate responses based on the user's message.
# The MTLLM model generates a response based on the user's message, chat history, agent role, and retrieved context.
# The assistant's response is added to the chat history.
# The response is reported back to the frontend. Here we are the using the special report keyword. This is one of the key feature of jac-cloud and operates a bit like a return statement but it does not stop the execution of the walker. It simply add whatever is reported to the response object that is sent back to the frontend.
    can chat with Session entry {
        here.chat_history.append({"role": "user", "content": self.message});
        data = rag_engine.get_from_chroma(query=self.message);
        response = here.llm_chat(
            message=self.message,
            chat_history=here.chat_history,
            agent_role="You are a conversation agent designed to help users with their queries based on the documents provided",
            context=data
        );

        here.chat_history.append({"role": "assistant", "content": response});

        report {"response": response};
    }
}