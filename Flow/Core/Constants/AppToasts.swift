import Foundation

/// Uygulamadaki hazır toast'lar. Her erişimde yeni kimlikli bir `Toast` üretilir.
enum AppToasts {

    // MARK: - Transaction

    static var transactionAdded: Toast {
        .success(
            title: "Transaction Success!",
            message: "New transaction added."
        )
    }

    static var transactionUpdated: Toast {
        .success(
            title: "Transaction Updated!",
            message: "Your transaction has been updated."
        )
    }

    static var transactionError: Toast {
        .error(
            title: "Transaction Failed!",
            message: "Something went wrong. Please try again."
        )
    }

    static var transactionDeleteError: Toast {
        .error(
            title: "Delete Failed",
            message: "The transaction couldn't be deleted. Please try again."
        )
    }

    static var invalidAmount: Toast {
        .warning(
            title: "Invalid Amount",
            message: "Please enter an amount greater than zero."
        )
    }

    // MARK: - Notifications

    static var reminderError: Toast {
        .error(
            title: "Reminder Not Set",
            message: "We couldn't schedule your reminder. Please try again."
        )
    }

    // MARK: - Profile

    static var profileUpdated: Toast {
        .success(
            title: "Profile Updated",
            message: "Your profile has been updated successfully."
        )
    }

    static var profilePhotoError: Toast {
        .error(
            title: "Photo Not Saved",
            message: "We couldn't load that photo. Please try another one."
        )
    }

    // MARK: - Assistant

    static var conversationDeleteError: Toast {
        .error(
            title: "Delete Failed",
            message: "The conversation couldn't be deleted. Please try again."
        )
    }

    // MARK: - Support

    static var supportEmailCopied: Toast {
        .info(
            title: "Email Copied",
            message: "appsupport.flow@gmail.com copied to clipboard."
        )
    }

    // MARK: - Export

    static var exportSucceeded: Toast {
        .success(
            title: "Export Complete",
            message: "The CSV file has been saved."
        )
    }

    static var exportError: Toast {
        .error(
            title: "Export Failed",
            message: "The CSV file couldn't be saved. Please try again."
        )
    }
}
