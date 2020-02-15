import pandas as pd
from tensorflow_core.python.keras.layers import recurrent
import constants
import os


def get_rep(sentences):
    rep_dict = {}
    for sentence in sentences:
        for word in sentence:
            if word not in rep_dict:
                rep_dict[word] = len(rep_dict)
    return rep_dict


def get_input_to_rnn(sentences, rep_dict):
    result = []
    for sentence in sentences:
        result.append([rep_dict.get(word) for word in sentence])
    return result


# Read train and test data into dataframe
train_data = pd.read_csv(os.path.join(constants.PWD, 'train.csv'))
test_data = pd.read_csv(os.path.join(constants.PWD, 'test.csv'))

# Convert text into number format to be fed into the RNN
space_separated_dataset = [(tweet.split(' ')) for tweet in train_data['text']]
word_representations = get_rep(space_separated_dataset)
input_to_rnn = get_input_to_rnn(space_separated_dataset, word_representations)
train_output = train_data['target'].values

cell = recurrent.SimpleRNN(4)
