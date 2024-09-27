# code for frontend chat interface

import:py streamlit as st;
import:py requests;

# streamlit handles the user interface (UI) of the chatbot
# requests will handle API calls to backend

can bootstrap_frontend (token: str) {
    # Add welcome message to the app
    st.write("Welcome to your Demo Agent!"); 

    # Initialize chat history (stored in session state variable)
    if "messages" not in st.session_state {
        st.session_state.messages = [];
    }

    # Loops through stored messages in session state
    # displays message by its role (either "user" or "assistant")
    for message in st.session_state.messages {
        with st.chat_message(message["role"]){
            st.markdown(message["content"]);
        }
    }

    if prompt := st.chat_input("What is up?"){
        # Add user message to chat history
        st.session_state.messages.append({"role":"user", "content":prompt});

        # Display user message in chat message container
        with st.chat_message("user"){
            st.markdown(prompt);
        }

        # Display chat assistant's response in chat message container
        with st.chat_message("assistant"){
            # Call walker API
            response = requests.post("http://localhost:8000/walker/interact", json={"message": prompt, "session_id": "123"},
                headers={"Authorization": f"Bearer {token}"}
            );

            if response.status_code == 200 {
                response = response.json();
                print(response);
                st.write(response["reports"][0]["response"]);

                # Add the assistant's response to chat history
                st.session_state.messages.append({"role":"assistant", "content":response["reports"][0]["response"]});
            }
        }
    }
}

# kind of like the main function of python program
# authenticate the user and retrieve the token needed for the bootstrap_frontend function

with entry {

    INSTANCE_URL = "http://localhost:8000";
    TEST_USER_EMAIL = "test@mail.com";
    TEST_USER_PASSWORD = "password";

    response = requests.post(
        f"{INSTANCE_URL}/user/login",
        json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
    );

    if response.status_code != 200 {
        # Try registering the user if login fails
        response = requests.post(
            f"{INSTANCE_URL}/user/register",
            json={
                "email": TEST_USER_EMAIL,
                "password": TEST_USER_PASSWORD
            }
        );
        assert response.status_code == 201;

        response = requests.post(
            f"{INSTANCE_URL}/user/login",
            json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}
        );
        assert response.status_code == 200;
    }

    token = response.json()["token"];

    print("Token:", token);

    bootstrap_frontend(token);
}

# Run the frontend with the command: < jac streamlit client.jac >
