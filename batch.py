from sklearn.svm import OneClassSVM
from util.predict import predict
import sys

def main():
    print("[*] Classifier Accuracy for Attacks:")
    count = 0
    for i in range(54):
        log = "data-capture/log/attack" + str(i).zfill(2) + ".csv"
        pred = predict(log)
        if pred:
            count += 1
        print("  " + log + ": " + str(pred))

    print("  Identified " + str(count) + "/54 attacks")

    print("[*] Classifier Accuracy for Benign Data:")
    count = 0
    for i in range(20):
        log = "data-capture/log/benign" + str(i).zfill(2) + ".csv"
        pred = predict(log)
        if pred:
            count += 1
        print("  " + log + ": " + str(pred))

    print("  Misclassified " + str(count) + "/20 benign data")
if __name__ == "__main__":
    main()
