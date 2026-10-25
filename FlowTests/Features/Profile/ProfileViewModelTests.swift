import Testing
import Foundation
@testable import Flow

/// Fotoğraf seçimi `PhotosPickerItem` gerektirdiği için burada değil, fotoğraf deposu
/// `ProfileImageStoreTests`'te test ediliyor.
@Suite("ProfileViewModel")
@MainActor
struct ProfileViewModelTests {

    @Test func editingStartsWithCurrentName() {
        let vm = ProfileViewModel()

        vm.showNameEditAlert(currentName: "Alex")

        #expect(vm.isNameEditAlertShowing)
        #expect(vm.nameEditText == "Alex")
    }

    @Test func cancelClosesAndClearsTheField() {
        let vm = ProfileViewModel()
        vm.showNameEditAlert(currentName: "Alex")

        vm.cancelNameEdit()

        #expect(!vm.isNameEditAlertShowing)
        #expect(vm.nameEditText.isEmpty)
    }

    @Test func savingTrimsAndStoresTheName() {
        TestDefaults.installIsolatedStore()
        let appState = AppState()
        let vm = ProfileViewModel()
        vm.showNameEditAlert(currentName: "")
        vm.nameEditText = "  Alex Morgan \n"

        let didChange = vm.saveName(to: appState)

        #expect(didChange)
        #expect(appState.userName == "Alex Morgan")
        #expect(!vm.isNameEditAlertShowing)
    }

    @Test func blankNameIsIgnored() {
        TestDefaults.installIsolatedStore()
        let appState = AppState()
        appState.userName = "Alex"
        let vm = ProfileViewModel()
        vm.nameEditText = "   "

        #expect(vm.saveName(to: appState) == false)
        #expect(appState.userName == "Alex")
    }

    @Test func unchangedNameIsNotReportedAsChange() {
        TestDefaults.installIsolatedStore()
        let appState = AppState()
        appState.userName = "Alex"
        let vm = ProfileViewModel()
        vm.nameEditText = "Alex"

        #expect(vm.saveName(to: appState) == false)
    }
}
