import SwiftUI

struct FileBrowserView: View {
    let directory: URL
    let title: String

    @State private var items: [PageItem] = []
    @State private var activeSheet: ActiveSheet?
    @State private var activeCover: ActiveCover?
    @State private var itemPendingDelete: PageItem?
    @State private var isConfirmingBulkDelete = false
    @State private var errorMessage: String?
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<PageItem>()

    private enum ActiveSheet: Identifiable {
        case newFolder
        case newPage
        case rename(PageItem)

        var id: String {
            switch self {
            case .newFolder: return "newFolder"
            case .newPage: return "newPage"
            case .rename(let item): return "rename-\(item.id)"
            }
        }
    }

    private enum ActiveCover: Identifiable {
        case importPicker

        var id: String { "importPicker" }
    }

    var body: some View {
        ZStack {
            HVColor.background.ignoresSafeArea()

            if items.isEmpty {
                emptyState
            } else if editMode == .active {
                List(selection: $selection) {
                    ForEach(items) { item in
                        row(for: item)
                            .tag(item)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(HVColor.background)
                .environment(\.editMode, $editMode)
            } else {
                List {
                    ForEach(items) { item in
                        row(for: item)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(HVColor.background)
                .environment(\.editMode, $editMode)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(HVColor.background, for: .navigationBar)
        .toolbarColorScheme(ThemeManager.shared.current.colorScheme, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        activeSheet = .newFolder
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                    Button {
                        activeSheet = .newPage
                    } label: {
                        Label("New HTML Page", systemImage: "doc.badge.plus")
                    }
                    Button {
                        activeCover = .importPicker
                    } label: {
                        Label("Import File", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(HVColor.accent)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(editMode == .active ? "Done" : "Select") {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                    if editMode == .inactive { selection.removeAll() }
                }
                .foregroundStyle(HVColor.accent)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if editMode == .active && !selection.isEmpty {
                    Button(role: .destructive) {
                        isConfirmingBulkDelete = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .foregroundStyle(HVColor.danger)
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newFolder:
                NameInputSheet(title: "New Folder", placeholder: "Folder name") { name in
                    createFolder(named: name)
                }
            case .newPage:
                NameInputSheet(title: "New HTML Page", placeholder: "page.html", initialValue: "page.html") { name in
                    createPage(named: name)
                }
            case .rename(let item):
                NameInputSheet(
                    title: "Rename",
                    placeholder: "Name",
                    initialValue: item.name,
                    confirmTitle: "Save"
                ) { name in
                    rename(item, to: name)
                }
            }
        }
        .fullScreenCover(item: $activeCover) { cover in
            switch cover {
            case .importPicker:
                DocumentPickerView(
                    onPick: { urls in
                        activeCover = nil
                        importFiles(urls)
                    },
                    onCancel: {
                        activeCover = nil
                    }
                )
                .ignoresSafeArea()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { isPresented in if !isPresented { errorMessage = nil } }
        ), presenting: errorMessage) { _ in
            Button("OK") { errorMessage = nil }
        } message: { message in
            Text(message)
        }
        .confirmationDialog(
            "Delete \"\(itemPendingDelete?.name ?? "")\"?",
            isPresented: Binding(
                get: { itemPendingDelete != nil },
                set: { isPresented in if !isPresented { itemPendingDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let item = itemPendingDelete { delete(item) }
                itemPendingDelete = nil
            }
            Button("Cancel", role: .cancel) { itemPendingDelete = nil }
        }
        .confirmationDialog(
            "Delete \(selection.count) item(s)?",
            isPresented: $isConfirmingBulkDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteSelection()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear(perform: reload)
    }

    private var emptyState: some View {
        VStack(spacing: HVSpacing.sm) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(HVColor.textSecondary)
            Text("Empty")
                .font(HVFont.body)
                .foregroundStyle(HVColor.textSecondary)
        }
    }

    @ViewBuilder
    private func row(for item: PageItem) -> some View {
        Group {
            if item.isDirectory {
                NavigationLink {
                    FileBrowserView(directory: item.url, title: item.name)
                } label: {
                    rowLabel(for: item)
                }
            } else {
                NavigationLink {
                    PagePreviewView(item: item)
                } label: {
                    rowLabel(for: item)
                }
            }
        }
        .listRowBackground(HVColor.background)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                itemPendingDelete = item
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                activeSheet = .rename(item)
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(HVColor.accent)
        }
        .contextMenu {
            Button {
                activeSheet = .rename(item)
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            if !item.isDirectory {
                ShareLink(item: item.url) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            Button(role: .destructive) {
                itemPendingDelete = item
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func rowLabel(for item: PageItem) -> some View {
        HStack(spacing: HVSpacing.md) {
            Image(systemName: icon(for: item))
                .foregroundStyle(HVColor.accent)
                .font(.system(size: 20))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(HVFont.body)
                    .foregroundStyle(HVColor.textPrimary)
                if !item.isDirectory {
                    Text("\(item.formattedSize) · \(item.formattedDate)")
                        .font(HVFont.caption)
                        .foregroundStyle(HVColor.textSecondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, HVSpacing.xs)
    }

    private func icon(for item: PageItem) -> String {
        if item.isDirectory { return "folder.fill" }
        if item.isHTML { return "chevron.left.slash.chevron.right" }
        return "doc"
    }

    private func reload() {
        do {
            items = try FileSystemService.shared.contents(of: directory)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importFiles(_ urls: [URL]) {
        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                let name = FileSystemService.shared.uniqueName(for: url.lastPathComponent, in: directory)
                try FileSystemService.shared.createFile(named: name, in: directory, contents: data)
                try? FileManager.default.removeItem(at: url)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        reload()
    }

    private func createFolder(named name: String) {
        do {
            try FileSystemService.shared.createFolder(named: name, in: directory)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func createPage(named name: String) {
        let boilerplate = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <title>New Page</title>
        </head>
        <body>

        </body>
        </html>
        """
        do {
            let finalName = name.lowercased().hasSuffix(".html") || name.lowercased().hasSuffix(".htm") ? name : "\(name).html"
            try FileSystemService.shared.createFile(named: finalName, in: directory, contents: Data(boilerplate.utf8))
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func rename(_ item: PageItem, to newName: String) {
        do {
            try FileSystemService.shared.rename(item, to: newName)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func delete(_ item: PageItem) {
        do {
            try FileSystemService.shared.delete(item)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteSelection() {
        for item in selection {
            do {
                try FileSystemService.shared.delete(item)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        selection.removeAll()
        editMode = .inactive
        reload()
    }
}
