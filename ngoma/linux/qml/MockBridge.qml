pragma Singleton
import QtQuick

// Mock du pont UI <-> TModeler (compte + messagerie).
// Remplacer par un pont adossé à TModeler en gardant les mêmes propriétés et fonctions.
QtObject {
    id: bridge

    // --- Compte ---
    property var user: null          // { id, name } ou null
    function restoreSession() { return user }
    function login(identifier, password) {
        user = { id: 1, name: identifier.trim() || "Moi" }
        return user
    }
    function register(name, identifier, password) {
        user = { id: 1, name: name.trim() || "Moi" }
        return user
    }
    function logout() { user = null }

    // --- Messagerie ---
    readonly property int me: 1
    property int nextId: 100
    property var conversations: [
        { id: 1, title: "Awa Traoré", unread: 2, pinned: true, muted: false, archived: false },
        { id: 2, title: "Équipe NGoma", unread: 0, pinned: false, muted: false, archived: false },
        { id: 3, title: "Kofi Mensah", unread: 1, pinned: false, muted: false, archived: false },
        { id: 4, title: "Fatou Diop", unread: 0, pinned: false, muted: true, archived: false }
    ]
    property var messages: {
        var now = Date.now()
        return [
            { id: 1, conversationId: 1, authorId: 2, text: "Salut ! Tu as vu le nouveau projet ?", time: now - 3600000, reactions: {} },
            { id: 2, conversationId: 1, authorId: 2, text: "On commence demain matin.", time: now - 3500000, reactions: {} },
            { id: 3, conversationId: 2, authorId: 3, text: "Bienvenue dans l'équipe NGoma.", time: now - 86400000, reactions: {} },
            { id: 4, conversationId: 2, authorId: 1, text: "Merci, content d'être là !", time: now - 86000000, reactions: {} },
            { id: 5, conversationId: 3, authorId: 4, text: "Tu peux m'envoyer le rapport ?", time: now - 7200000, reactions: {} },
            { id: 6, conversationId: 4, authorId: 5, text: "Bonne journée à tous.", time: now - 172800000, reactions: {} }
        ]
    }

    function messagesOf(conversationId) {
        return messages.filter(function (m) { return m.conversationId === conversationId })
    }
    function lastMessage(conversationId) {
        var list = messagesOf(conversationId).filter(function (m) { return !m.deleted })
        return list.length ? list[list.length - 1] : null
    }

    function _patchMessage(id, f) {
        messages = messages.map(function (m) { return m.id === id ? f(m) : m })
    }
    function _patchConv(id, f) {
        conversations = conversations.map(function (c) { return c.id === id ? f(c) : c })
    }
    function _add(conversationId, authorId, text, replyToId) {
        messages = messages.concat([{
            id: nextId++, conversationId: conversationId, authorId: authorId,
            text: text, time: Date.now(), replyToId: replyToId || 0, reactions: {}
        }])
    }

    property var _pendingReplies: []
    function send(conversationId, text, replyToId) {
        _add(conversationId, me, text, replyToId)
        _pendingReplies = _pendingReplies.concat([conversationId])
        peerTimer.restart()
    }
    function edit(id, text) {
        _patchMessage(id, function (m) { var n = Object.assign({}, m); n.text = text; n.edited = true; return n })
    }
    function remove(id) {
        _patchMessage(id, function (m) { var n = Object.assign({}, m); n.text = ""; n.deleted = true; return n })
    }
    function react(id, emoji) {
        _patchMessage(id, function (m) {
            var n = Object.assign({}, m)
            n.reactions = Object.assign({}, m.reactions)
            n.reactions[emoji] = (n.reactions[emoji] || 0) + 1
            return n
        })
    }
    function markRead(id) {
        _patchConv(id, function (c) { return Object.assign({}, c, { unread: 0 }) })
    }
    function setPinned(id, v) { _patchConv(id, function (c) { return Object.assign({}, c, { pinned: v }) }) }
    function setMuted(id, v) { _patchConv(id, function (c) { return Object.assign({}, c, { muted: v }) }) }
    function setArchived(id, v) { _patchConv(id, function (c) { return Object.assign({}, c, { archived: v }) }) }
    function createConversation(title) {
        var id = 1
        conversations.forEach(function (c) { id = Math.max(id, c.id + 1) })
        conversations = conversations.concat([{ id: id, title: title, unread: 0, pinned: false, muted: false, archived: false }])
        return id
    }

    // Réponse simulée d'un interlocuteur
    property Timer peerTimer: Timer {
        interval: 1500
        onTriggered: {
            var ids = bridge._pendingReplies
            bridge._pendingReplies = []
            ids.forEach(function (cid) {
                bridge._add(cid, 2, "Bien reçu 👍", 0)
                bridge._patchConv(cid, function (c) { return Object.assign({}, c, { unread: c.unread + 1 }) })
            })
        }
    }
}
