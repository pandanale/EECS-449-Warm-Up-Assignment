# Contains code for the Retrieval Augmented Gneration module

import:py os;

# To load documents from a directory
import:py from langchain_community.document_loaders {PyPDFDirectoryLoader}

# To split the documents into chunks
import:py from langchain_text_splitters {RecursiveCharacterTextSplitter}

import:py from langchain.schema.document {Document}

# Generate embeddings from document chunks
import:py from langchain_community.embeddings.ollama {OllamaEmbeddings}

# Chroma is the vector store for storing the embeddings
import:py from langchain_community.vectorstores.chroma {Chroma}

# obj is similar to dataclasses in python
obj RagEngine {
    has file_path: str = "docs"; # specifies the path to the dir containing the documents we want to retrieve responses from
    has chroma_path: str = "chroma"; # specifies the path to the dir containing the pre-trained embeddings



    can postinit {
        documents: list = self.load_documents();
        chunks: list = self.split_documents(documents);
        self.add_to_chroma(chunks);
    }

    # The add_to_chroma method adds the chunks to the Chroma vector store.

    # The load_documents method loads the documents from the specified directory using the PyPDFDirectoryLoader class.

    can load_documents {
        document_loader = PyPDFDirectoryLoader(self.file_path);
        return document_loader.load();
    }

    # The split_documents method splits the documents into chunks using the RecursiveCharacterTextSplitter class. 
    # This ensures that documents are broken down into manageable chunks for better embedding and retrieval performance.
    can split_documents(documents: list[Document]) {
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=800,
        chunk_overlap=80,
        length_function=len,
        is_separator_regex=False);
        return text_splitter.split_documents(documents);
    }

    # The get_embedding_function ability uses the OllamaEmbeddingsmodel to create embeddings for the document chunks. 
    # These embeddings are crucial for semantic search in the vector database.
    can get_embedding_function {
        embeddings = OllamaEmbeddings(model='nomic-embed-text');
        return embeddings;
    }

    # each chunk of text needs a unique identifier to ensure that it can be referenced in the vector store. 
    # The add_chunk_id ability assigns IDs to each chunk, using the format Page Source:Page Number:Chunk Index.
    can add_chunk_id(chunks: str) {
        last_page_id = None;
        current_chunk_index = 0;

        for chunk in chunks {
            source = chunk.metadata.get('source');
            page = chunk.metadata.get('page');
            current_page_id = f'{source}:{page}';

            if current_page_id == last_page_id {
                current_chunk_index +=1;
            } else {
                current_chunk_index = 0;
            }

            chunk_id = f'{current_page_id}:{current_chunk_index}';
            last_page_id = current_page_id;

            chunk.metadata['id'] = chunk_id;
        }

        return chunks;
    }

    can add_to_chroma(chunks: list[Document]) {
        db = Chroma(persist_directory=self.chroma_path, embedding_function=self.get_embedding_function());
        chunks_with_ids = self.add_chunk_id(chunks);

        existing_items = db.get(include=[]);
        existing_ids = set(existing_items['ids']);

        new_chunks = [];
        for chunk in chunks_with_ids {
            if chunk.metadata['id'] not in existing_ids {
                new_chunks.append(chunk);
            }
        }

        if len(new_chunks) {
            print('adding new documents');
            new_chunk_ids = [chunk.metadata['id'] for chunk in new_chunks];
            db.add_documents(new_chunks, ids=new_chunk_ids);
        } else {
            print('no new documents to add');
        }
    }

    can get_from_chroma(query: str,chunck_nos: int=5) {
        db = Chroma(
            persist_directory=self.chroma_path,
            embedding_function=self.get_embedding_function()
        );
        results = db.similarity_search_with_score(query,k=chunck_nos);
        return results;
    }

# To summarize, we define an object called RagEngine with two properties: file_path and chroma_path. 
# The file_path property specifies the path to the directory containing the documents we want to retrieve responses from. 
# The chroma_path property specifies the path to the directory containing the pre-trained embeddings. 
#We will use these embeddings to retrieve candidate responses.

# We define a few methods to load the documents, split them into chunks, and add them to the Chroma vector store. 
# We also define a method to retrieve candidate responses based on a query. Let's break down the code:

# The load_documents method loads the documents from the specified directory using the PyPDFDirectoryLoader class.
# The split_documents method splits the documents into chunks using the RecursiveCharacterTextSplitter class from the langchain_text_splitters module.
# The get_embedding_function method initializes the Ollama embeddings model.
# The add_chunk_id method generates unique IDs for the chunks based on the source and page number.
# The add_to_chroma method adds the chunks to the Chroma vector store.
# The get_from_chroma method retrieves candidate responses based on a query from the Chroma vector store.
}
