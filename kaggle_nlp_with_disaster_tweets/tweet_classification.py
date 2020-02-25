import pandas as pd
import numpy as np
from tensorflow_core.python.keras import backend
from tensorflow_core.python.keras.losses import BinaryCrossentropy
from tensorflow_core.python.keras.models import Sequential
from tensorflow_core.python.keras.layers.recurrent import LSTM
from tensorflow_core.python.keras.layers.embeddings import Embedding
from tensorflow_core.python.keras.layers.core import Dense
import constants
import os


def get_rep(sentences):
    rep_dict = {}
    max_words = 0
    for sentence in sentences:
        word_count = 0
        for word in sentence:
            word_count += 1
            if word not in rep_dict:
                rep_dict[word] = len(rep_dict)+1
        max_words = max(word_count, max_words)
    return rep_dict, max_words


def get_input_to_rnn(sentences, representation, max_words):
    result = []
    for sentence in sentences:
        sentence_rep = [representation.get(word) for word in sentence]
        sentence_rep.extend([0] * (max_words - len(sentence_rep)))
        result.append(sentence_rep)
    return result


# Read train and test data into dataframe
train_data = pd.read_csv(os.path.join(constants.PWD, 'train.csv'))
test_data = pd.read_csv(os.path.join(constants.PWD, 'test.csv'))

# Convert text into number format to be fed into the RNN
space_separated_dataset = [(tweet.split(' ')) for tweet in train_data['text']]
word_rep_dict, max_len = get_rep(space_separated_dataset)
input_to_rnn = get_input_to_rnn(space_separated_dataset, word_rep_dict, max_len)
train_output = train_data['target'].values

train_data = backend.constant(np.asarray(input_to_rnn))
target = backend.constant(np.asarray(train_output))
split_at = len(train_data) - len(train_data) // 10
(x_train, x_val) = train_data[:split_at], train_data[split_at:]
(y_train, y_val) = target[:split_at], target[split_at:]
model = Sequential([
    # Input layer - embedding
    Embedding(input_dim=len(word_rep_dict)+1, input_shape=(54,), output_dim=64, mask_zero=True),
    # RNN layer
    LSTM(units=64),
    # Output layer - dense
    Dense(units=1, activation='sigmoid')
])

model.compile(loss=BinaryCrossentropy(from_logits=True),
              optimizer='adam')

history = model.fit(x=x_train, y=y_train)
predictions = model.predict(x_val)
incorrect_predictions = 0
for i in range(len(predictions)):
    expected = y_val[i]
    actual = round(predictions[i][0])
    if expected != actual:
        incorrect_predictions += 1
        print(expected, actual)
accuracy = 1-(incorrect_predictions/len(predictions))
print(accuracy)
